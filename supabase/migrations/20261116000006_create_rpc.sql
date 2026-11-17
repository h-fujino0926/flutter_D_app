-- =============================================================
-- RPC（Flutter から supabase.rpc('関数名', params: {...}) で呼ぶ関数）
--
--   ・すべて security definer / set search_path = ''。
--   ・関数の最初でログインと権限を確認する。
--   ・エラーは raise exception 'コード' で返す（Flutter 側で日本語に変換：
--     lib/core/errors/error_messages.dart）。
--   ・例外：join_team は失敗回数を確実に保存するため、エラーも戻り値で返す（A2）。
-- =============================================================

-- -------------------------------------------------------------
-- チーム作成：チーム → 自分を leader で追加 → 初期ボード「メイン」
-- -------------------------------------------------------------
create or replace function public.create_team(p_name text, p_description text default null)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_team_id bigint;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if p_name is null or char_length(trim(p_name)) not between 1 and 30 then
    raise exception 'INVALID_INPUT';
  end if;

  insert into public.teams (name, description, owner_user_id)
  values (trim(p_name), nullif(trim(p_description), ''), v_uid)
  returning team_id into v_team_id;

  insert into public.team_members (team_id, user_id, role)
  values (v_team_id, v_uid, 'leader');

  insert into public.boards (team_id, name, created_by)
  values (v_team_id, 'メイン', v_uid);

  return v_team_id;
end;
$$;

-- -------------------------------------------------------------
-- チーム削除（論理削除）：owner のみ
-- -------------------------------------------------------------
create or replace function public.delete_team(p_team_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if not exists (
    select 1 from public.teams t
    where t.team_id = p_team_id and t.owner_user_id = v_uid and t.deleted_at is null
  ) then
    raise exception 'FORBIDDEN';
  end if;

  update public.teams set deleted_at = now() where team_id = p_team_id;
end;
$$;

-- -------------------------------------------------------------
-- 招待の発行：leader のみ。平文パスコードを返すのはこの1回だけ。
-- 仮決定（A3）：参加には URL（token）とパスコードの両方が必要なので、
--              パスコードの重複チェックはしない。
-- -------------------------------------------------------------
create or replace function public.create_invite(p_team_id bigint, p_max_uses int default 0)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  -- 紛らわしい 0 O 1 I を除いた 32 文字（256 の約数なので偏りが出ない）
  c_alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_bytes bytea := extensions.gen_random_bytes(6);
  v_passcode text := '';
  v_token text := encode(extensions.gen_random_bytes(24), 'hex');
  v_expires_at timestamptz := now() + interval '72 hours';
  v_invitation_id bigint;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if not private.is_team_leader(p_team_id) then
    raise exception 'FORBIDDEN';
  end if;
  if p_max_uses is null or p_max_uses < 0 then
    raise exception 'INVALID_INPUT';
  end if;

  for i in 0..5 loop
    v_passcode := v_passcode || substr(c_alphabet, (get_byte(v_bytes, i) % 32) + 1, 1);
  end loop;

  insert into public.team_invites
    (team_id, token, passcode_hash, created_by, expires_at, max_uses)
  values
    (p_team_id, v_token, private.hash_passcode(v_passcode), v_uid, v_expires_at, p_max_uses)
  returning invitation_id into v_invitation_id;

  return jsonb_build_object(
    'invitation_id', v_invitation_id,
    'token', v_token,
    'passcode', v_passcode,
    'expires_at', v_expires_at
  );
end;
$$;

-- -------------------------------------------------------------
-- 招待の無効化：leader のみ
-- -------------------------------------------------------------
create or replace function public.revoke_invite(p_invitation_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_team_id bigint;
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  select i.team_id into v_team_id from public.team_invites i where i.invitation_id = p_invitation_id;
  if v_team_id is null or not private.is_team_leader(v_team_id) then
    raise exception 'FORBIDDEN';
  end if;

  update public.team_invites
  set revoked_at = now()
  where invitation_id = p_invitation_id and revoked_at is null;
end;
$$;

-- -------------------------------------------------------------
-- 招待で参加
-- 戻り値：{ok: true, team_id, already_member} または {ok: false, code, remaining_attempts?}
--   例外を投げると failed_attempts の更新まで巻き戻ってしまうため、
--   参加の失敗は例外ではなく戻り値で返す（A2）。
-- 判定順：存在/無効化 → 期限 → 使用上限 → パスコード → 既存メンバー → 追加
-- -------------------------------------------------------------
create or replace function public.join_team(p_token text, p_passcode text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_invite public.team_invites%rowtype;
  v_member public.team_members%rowtype;
  v_failed int;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  -- 同時に参加されたときに used_count がずれないよう行ロックする
  select i.* into v_invite
  from public.team_invites i
  join public.teams t on t.team_id = i.team_id and t.deleted_at is null
  where i.token = p_token
  for update of i;

  if not found or v_invite.revoked_at is not null then
    return jsonb_build_object('ok', false, 'code', 'INVITE_NOT_FOUND');
  end if;
  if v_invite.expires_at <= now() then
    return jsonb_build_object('ok', false, 'code', 'INVITE_EXPIRED');
  end if;
  if v_invite.max_uses > 0 and v_invite.used_count >= v_invite.max_uses then
    return jsonb_build_object('ok', false, 'code', 'INVITE_LIMIT');
  end if;

  if p_passcode is null or private.hash_passcode(p_passcode) <> v_invite.passcode_hash then
    v_failed := v_invite.failed_attempts + 1;
    update public.team_invites
    set failed_attempts = v_failed,
        revoked_at = case when v_failed >= 5 then now() else revoked_at end
    where invitation_id = v_invite.invitation_id;
    return jsonb_build_object(
      'ok', false,
      'code', 'WRONG_PASSCODE',
      'remaining_attempts', greatest(5 - v_failed, 0)
    );
  end if;

  select m.* into v_member
  from public.team_members m
  where m.team_id = v_invite.team_id and m.user_id = v_uid;

  if found and v_member.left_at is null then
    -- すでにメンバー：何もせず team_id を返す
    return jsonb_build_object('ok', true, 'team_id', v_invite.team_id, 'already_member', true);
  end if;

  if found then
    -- 退出済み：一般メンバーとして再参加
    update public.team_members
    set left_at = null, role = 'member', joined_at = now()
    where team_member_id = v_member.team_member_id;
  else
    insert into public.team_members (team_id, user_id, role)
    values (v_invite.team_id, v_uid, 'member');
  end if;

  update public.team_invites
  set used_count = used_count + 1
  where invitation_id = v_invite.invitation_id;

  return jsonb_build_object('ok', true, 'team_id', v_invite.team_id, 'already_member', false);
end;
$$;

-- -------------------------------------------------------------
-- チーム退出：owner は退出不可（B13）、最後のリーダーも退出不可
-- -------------------------------------------------------------
create or replace function public.leave_team(p_team_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_member public.team_members%rowtype;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  select m.* into v_member
  from public.team_members m
  where m.team_id = p_team_id and m.user_id = v_uid and m.left_at is null;
  if not found then
    raise exception 'NOT_FOUND';
  end if;

  if exists (select 1 from public.teams t where t.team_id = p_team_id and t.owner_user_id = v_uid) then
    raise exception 'OWNER_CANNOT_LEAVE';
  end if;

  if v_member.role = 'leader' and not exists (
    select 1 from public.team_members m
    where m.team_id = p_team_id and m.role = 'leader' and m.left_at is null and m.user_id <> v_uid
  ) then
    raise exception 'LAST_LEADER';
  end if;

  update public.team_members set left_at = now() where team_member_id = v_member.team_member_id;

  -- 前回のチーム・ボードがこのチームなら消しておく
  update public.user_settings
  set last_team_id = null, last_board_id = null
  where user_id = v_uid and last_team_id = p_team_id;
end;
$$;

-- -------------------------------------------------------------
-- ロール変更：leader のみ。owner のロールは変更不可（F4）。最後のリーダーは降格不可。
-- -------------------------------------------------------------
create or replace function public.change_member_role(
  p_team_id bigint,
  p_user_id uuid,
  p_role public.team_role
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_target public.team_members%rowtype;
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if not private.is_team_leader(p_team_id) then
    raise exception 'FORBIDDEN';
  end if;

  select m.* into v_target
  from public.team_members m
  where m.team_id = p_team_id and m.user_id = p_user_id and m.left_at is null;
  if not found then
    raise exception 'NOT_FOUND';
  end if;

  if exists (select 1 from public.teams t where t.team_id = p_team_id and t.owner_user_id = p_user_id) then
    raise exception 'OWNER_ROLE_LOCKED';
  end if;

  if v_target.role = 'leader' and p_role = 'member' and not exists (
    select 1 from public.team_members m
    where m.team_id = p_team_id and m.role = 'leader' and m.left_at is null and m.user_id <> p_user_id
  ) then
    raise exception 'LAST_LEADER';
  end if;

  update public.team_members set role = p_role where team_member_id = v_target.team_member_id;
end;
$$;

-- -------------------------------------------------------------
-- タスク完了（履歴と通知はトリガー）
-- -------------------------------------------------------------
create or replace function public.complete_task(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  select t.* into v_task from public.tasks t where t.task_id = p_task_id for update;
  if not found or not private.is_team_member(v_task.team_id) then
    raise exception 'NOT_FOUND';
  end if;
  if v_task.deleted_at is not null then
    raise exception 'TASK_DELETED';
  end if;
  if v_task.status = 'done' then
    raise exception 'TASK_ALREADY_DONE';
  end if;
  if not private.can_edit_task(p_task_id) then
    raise exception 'FORBIDDEN';
  end if;

  update public.tasks
  set status = 'done', completed_at = now(), completed_by = v_uid
  where task_id = p_task_id;
end;
$$;

-- -------------------------------------------------------------
-- 完了の取り消し：自分が完了させて 10秒以内のときだけ。
-- 戻す先は履歴から取る（B6：クライアントから受け取らない）。
-- 仮決定（B5/F3）：すでに送った完了通知は消さない。
-- -------------------------------------------------------------
create or replace function public.undo_complete(p_task_id bigint)
returns public.task_status
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
  v_prev public.task_status;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  select t.* into v_task from public.tasks t where t.task_id = p_task_id for update;
  if not found or not private.is_team_member(v_task.team_id) then
    raise exception 'NOT_FOUND';
  end if;
  if v_task.status <> 'done' then
    raise exception 'TASK_NOT_DONE';
  end if;
  if v_task.completed_by is distinct from v_uid then
    raise exception 'FORBIDDEN';
  end if;
  if v_task.completed_at < now() - interval '10 seconds' then
    raise exception 'UNDO_EXPIRED';
  end if;

  select h.from_status into v_prev
  from public.task_status_history h
  where h.task_id = p_task_id and h.to_status = 'done'
  order by h.created_at desc, h.history_id desc
  limit 1;

  v_prev := coalesce(v_prev, 'todo');
  update public.tasks set status = v_prev where task_id = p_task_id;
  return v_prev;
end;
$$;

-- -------------------------------------------------------------
-- レビュー（承認／差し戻し）：leader のみ
-- 仮決定（B7/F2）：通知は「タスクを完了した人」へ送る。
-- -------------------------------------------------------------
create or replace function public.review_task(
  p_task_id bigint,
  p_approve boolean,
  p_comment text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
  v_comment text := nullif(trim(p_comment), '');
  v_actor_name text;
begin
  if v_uid is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  select t.* into v_task from public.tasks t where t.task_id = p_task_id for update;
  if not found or not private.is_team_member(v_task.team_id) then
    raise exception 'NOT_FOUND';
  end if;
  if not private.is_team_leader(v_task.team_id) then
    raise exception 'FORBIDDEN';
  end if;
  if v_task.deleted_at is not null then
    raise exception 'TASK_DELETED';
  end if;
  if v_task.status <> 'done' then
    raise exception 'TASK_NOT_DONE';
  end if;

  select p.display_name into v_actor_name from public.profiles p where p.id = v_uid;

  if p_approve then
    update public.tasks
    set reviewed_at = now(), reviewed_by = v_uid
    where task_id = p_task_id;

    if v_task.completed_by is not null and v_task.completed_by <> v_uid then
      insert into public.notifications
        (recipient_user_id, actor_user_id, team_id, task_id, type, message)
      values (
        v_task.completed_by, v_uid, v_task.team_id, v_task.task_id, 'task_approved',
        format('%sさんがタスク【%s】を承認しました', coalesce(v_actor_name, '誰か'), v_task.title)
      );
    end if;
  else
    if v_comment is null then
      raise exception 'COMMENT_REQUIRED';
    end if;
    if char_length(v_comment) > 100 then
      raise exception 'INVALID_INPUT';
    end if;

    -- 履歴トリガーにコメントを渡す（このトランザクション内だけ有効）
    perform set_config('app.status_comment', v_comment, true);
    update public.tasks
    set latest_comment = v_comment, status = 'in_progress', returned_at = now()
    where task_id = p_task_id;
    perform set_config('app.status_comment', '', true);

    if v_task.completed_by is not null and v_task.completed_by <> v_uid then
      insert into public.notifications
        (recipient_user_id, actor_user_id, team_id, task_id, type, message)
      values (
        v_task.completed_by, v_uid, v_task.team_id, v_task.task_id, 'task_returned',
        format('%sさんがタスク【%s】を差し戻しました：%s',
               coalesce(v_actor_name, '誰か'), v_task.title, v_comment)
      );
    end if;
  end if;
end;
$$;

-- -------------------------------------------------------------
-- 付箋の削除（ゴミ箱へ。論理削除）
-- -------------------------------------------------------------
create or replace function public.delete_task(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if not private.can_delete_task(p_task_id) then
    raise exception 'FORBIDDEN';
  end if;

  update public.tasks
  set deleted_at = now()
  where task_id = p_task_id and deleted_at is null;
end;
$$;

-- -------------------------------------------------------------
-- ゴミ箱から復元（元の位置に他の付箋があれば少しずらす）
-- -------------------------------------------------------------
create or replace function public.restore_task(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_task public.tasks%rowtype;
  v_pos record;
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;
  if not private.can_delete_task(p_task_id) then
    raise exception 'FORBIDDEN';
  end if;

  select t.* into v_task from public.tasks t where t.task_id = p_task_id for update;
  if v_task.deleted_at is null then
    return;
  end if;

  select * into v_pos
  from private.find_free_position(v_task.board_id, v_task.task_id, v_task.pos_x, v_task.pos_y);

  update public.tasks
  set deleted_at = null, pos_x = v_pos.x, pos_y = v_pos.y
  where task_id = p_task_id;
end;
$$;

-- -------------------------------------------------------------
-- 完了ログから復元（todo に戻す。完了・承認情報はトリガーでクリア）
-- -------------------------------------------------------------
create or replace function public.restore_completed_task(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_task public.tasks%rowtype;
  v_pos record;
begin
  if auth.uid() is null then
    raise exception 'NOT_AUTHENTICATED';
  end if;

  select t.* into v_task from public.tasks t where t.task_id = p_task_id for update;
  if not found or not private.is_team_member(v_task.team_id) then
    raise exception 'NOT_FOUND';
  end if;
  if not private.can_edit_task(p_task_id) then
    raise exception 'FORBIDDEN';
  end if;
  if v_task.deleted_at is not null then
    raise exception 'TASK_DELETED';
  end if;
  if v_task.status <> 'done' then
    raise exception 'TASK_NOT_DONE';
  end if;

  select * into v_pos
  from private.find_free_position(v_task.board_id, v_task.task_id, v_task.pos_x, v_task.pos_y);

  update public.tasks
  set status = 'todo', pos_x = v_pos.x, pos_y = v_pos.y
  where task_id = p_task_id;
end;
$$;

-- -------------------------------------------------------------
-- 自分の担当タスク（ミニウィンドウ・スマホ用）
-- 所属する全チームの「自分が担当・未完了・未削除」を締切の近い順（締切なしは最後）
-- -------------------------------------------------------------
create or replace function public.get_my_tasks()
returns table (
  task_id        bigint,
  team_id        bigint,
  team_name      text,
  board_id       bigint,
  board_name     text,
  title          text,
  status         public.task_status,
  priority       public.task_priority,
  start_at       timestamptz,
  start_has_time boolean,
  due_at         timestamptz,
  due_has_time   boolean,
  color          text,
  latest_comment text,
  returned_at    timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    t.task_id, t.team_id, tm.name, t.board_id, b.name, t.title, t.status, t.priority,
    t.start_at, t.start_has_time, t.due_at, t.due_has_time, t.color,
    t.latest_comment, t.returned_at
  from public.tasks t
  join public.task_members a
    on a.task_id = t.task_id and a.user_id = (select auth.uid())
  join public.team_members m
    on m.team_id = t.team_id and m.user_id = (select auth.uid()) and m.left_at is null
  join public.teams tm
    on tm.team_id = t.team_id and tm.deleted_at is null
  join public.boards b
    on b.board_id = t.board_id
  where t.status <> 'done'
    and t.deleted_at is null
  order by t.due_at asc nulls last, t.task_id;
$$;

-- -------------------------------------------------------------
-- 実行権限：未ログイン（anon）からは呼べないようにする
-- -------------------------------------------------------------
revoke execute on all functions in schema public from public, anon;
grant execute on all functions in schema public to authenticated;
