-- =============================================================
-- トリガー
-- =============================================================

-- -------------------------------------------------------------
-- updated_at の自動更新
-- -------------------------------------------------------------
create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger set_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.teams
  for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.boards
  for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.user_settings
  for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.tasks
  for each row execute function private.set_updated_at();

-- -------------------------------------------------------------
-- 新規登録時に profiles と user_settings を作る
-- 表示名は signUp の data: {display_name: ...} から取る
-- -------------------------------------------------------------
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, email)
  values (
    new.id,
    left(
      coalesce(
        nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''),
        split_part(coalesce(new.email, ''), '@', 1),
        'ユーザー'
      ),
      20
    ),
    coalesce(new.email, new.id::text)
  );
  insert into public.user_settings (user_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- メールアドレスが変更されたら profiles.email も合わせる（B18）
create or replace function private.handle_user_email_updated()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_email_updated
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email and new.email is not null)
  execute function private.handle_user_email_updated();

-- -------------------------------------------------------------
-- tasks：直接 UPDATE されたときの制限と、関連列の自動設定
--
-- クライアント（authenticated ロール）から直接 UPDATE された場合：
--   ・ゴミ箱の付箋は編集できない（復元は RPC restore_task）
--   ・done にする／done から戻すのは RPC（complete_task 等）経由のみ
-- RPC（security definer）の中では current_user が関数の所有者になるので制限しない。
-- -------------------------------------------------------------
create or replace function private.guard_task_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user = 'authenticated' then
    if old.deleted_at is not null then
      raise exception 'TASK_DELETED';
    end if;
    if new.status is distinct from old.status
       and (new.status = 'done' or old.status = 'done') then
      raise exception 'FORBIDDEN';
    end if;
  end if;

  -- 一言メッセージを書き換えたら、書いた人と日時を記録
  if new.latest_comment is distinct from old.latest_comment then
    new.latest_comment_by := auth.uid();
    new.latest_comment_at := now();
  end if;

  if new.status is distinct from old.status then
    -- 完了から戻ったら完了・承認の情報を消す（B4, B9）
    if old.status = 'done' then
      new.completed_at := null;
      new.completed_by := null;
      new.reviewed_at := null;
      new.reviewed_by := null;
    end if;
    -- 再度完了したら「差し戻し中」を解除（B3）
    if new.status = 'done' then
      new.returned_at := null;
    end if;
  end if;

  return new;
end;
$$;

create trigger guard_task_update
  before update on public.tasks
  for each row execute function private.guard_task_update();

-- -------------------------------------------------------------
-- tasks：ステータス変更の履歴記録と完了通知
-- 差し戻しコメントは RPC review_task が set_config('app.status_comment', ...) で渡す。
-- -------------------------------------------------------------
create or replace function private.on_task_status_changed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_actor_name text;
begin
  insert into public.task_status_history
    (task_id, team_id, user_id, from_status, to_status, comment)
  values (
    new.task_id, new.team_id, v_actor, old.status, new.status,
    nullif(current_setting('app.status_comment', true), '')
  );

  if new.status = 'done' then
    select p.display_name into v_actor_name from public.profiles p where p.id = v_actor;

    -- リーダー全員＋作成者（操作した本人と、退出済みの人は除く）
    insert into public.notifications
      (recipient_user_id, actor_user_id, team_id, task_id, type, message)
    select r.user_id, v_actor, new.team_id, new.task_id, 'task_completed',
           format('%sさんがタスク【%s】を完了しました', coalesce(v_actor_name, '誰か'), new.title)
    from (
      select m.user_id
      from public.team_members m
      where m.team_id = new.team_id and m.role = 'leader' and m.left_at is null
      union
      select new.created_by
    ) r
    where r.user_id is distinct from v_actor
      and private.is_active_member(new.team_id, r.user_id);
  end if;

  return null;
end;
$$;

create trigger on_task_status_changed
  after update of status on public.tasks
  for each row
  when (old.status is distinct from new.status)
  execute function private.on_task_status_changed();

-- -------------------------------------------------------------
-- tasks：一言メッセージ更新の通知（担当者＋作成者、本人除く）
-- 差し戻し（ステータスも同時に変わる）のときは review_task が別の通知を出すので送らない。
-- -------------------------------------------------------------
create or replace function private.on_task_comment_changed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_actor_name text;
begin
  select p.display_name into v_actor_name from public.profiles p where p.id = v_actor;

  insert into public.notifications
    (recipient_user_id, actor_user_id, team_id, task_id, type, message)
  select r.user_id, v_actor, new.team_id, new.task_id, 'message_updated',
         format('%sさんがタスク【%s】のメッセージを更新しました', coalesce(v_actor_name, '誰か'), new.title)
  from (
    select a.user_id from public.task_members a where a.task_id = new.task_id
    union
    select new.created_by
  ) r
  where r.user_id is distinct from v_actor
    and private.is_active_member(new.team_id, r.user_id);

  return null;
end;
$$;

create trigger on_task_comment_changed
  after update of latest_comment on public.tasks
  for each row
  when (
    old.latest_comment is distinct from new.latest_comment
    and new.latest_comment is not null
    and old.status is not distinct from new.status
  )
  execute function private.on_task_comment_changed();

-- -------------------------------------------------------------
-- task_members：担当者はそのチームのアクティブなメンバーに限る
-- -------------------------------------------------------------
create or replace function private.check_task_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_active_member(private.task_team_id(new.task_id), new.user_id) then
    raise exception 'INVALID_INPUT';
  end if;
  return new;
end;
$$;

create trigger check_task_member
  before insert on public.task_members
  for each row execute function private.check_task_member();

-- -------------------------------------------------------------
-- task_members：担当者に割り当てられたら通知（自分で自分を割り当てた場合は除く）
-- -------------------------------------------------------------
create or replace function private.on_task_member_added()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_actor_name text;
  v_task public.tasks%rowtype;
begin
  if new.user_id is not distinct from v_actor then
    return null;
  end if;

  select * into v_task from public.tasks t where t.task_id = new.task_id;
  select p.display_name into v_actor_name from public.profiles p where p.id = v_actor;

  insert into public.notifications
    (recipient_user_id, actor_user_id, team_id, task_id, type, message)
  values (
    new.user_id, v_actor, v_task.team_id, v_task.task_id, 'task_assigned',
    format('%sさんがあなたをタスク【%s】の担当者にしました', coalesce(v_actor_name, '誰か'), v_task.title)
  );
  return null;
end;
$$;

create trigger on_task_member_added
  after insert on public.task_members
  for each row execute function private.on_task_member_added();
