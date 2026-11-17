-- =============================================================
-- 権限（GRANT）と行レベルセキュリティ（RLS）
--
-- 方針：
--   ・全テーブルで RLS を有効化する（RLS なしのテーブルを作らない）。
--   ・未ログイン（anon）には何も許可しない。
--   ・authenticated には「必要な列だけ」INSERT / UPDATE を許可する（列単位 GRANT）。
--     例：tasks.deleted_at や completed_at はクライアントから直接書けず、RPC 経由のみ。
--   ・ポリシー内の auth.uid() は (select auth.uid()) と書く（性能対策）。
--
-- 注意：Supabase は public に新しいテーブルを作ると anon / authenticated に
--       全権限を自動付与する。テーブルを追加したら、このファイルと同じように
--       revoke → 必要な分だけ grant すること。
-- =============================================================

-- -------------------------------------------------------------
-- RLS 有効化
-- -------------------------------------------------------------
alter table public.profiles            enable row level security;
alter table public.user_settings       enable row level security;
alter table public.teams               enable row level security;
alter table public.team_members        enable row level security;
alter table public.team_invites        enable row level security;
alter table public.boards              enable row level security;
alter table public.tasks               enable row level security;
alter table public.task_members        enable row level security;
alter table public.task_status_history enable row level security;
alter table public.notifications       enable row level security;

-- -------------------------------------------------------------
-- いったん全部取り上げてから、必要な分だけ与える
-- -------------------------------------------------------------
revoke all on all tables in schema public from anon, authenticated;

grant select on
  public.profiles, public.user_settings, public.teams, public.team_members,
  public.boards, public.tasks, public.task_members, public.task_status_history,
  public.notifications
to authenticated;
-- team_invites は SELECT も与えない（RPC のみ）

grant update (display_name, icon_color, last_login_at) on public.profiles to authenticated;

grant insert (user_id, last_team_id, last_board_id, mini_window_enabled, google_calendar_linked)
  on public.user_settings to authenticated;
grant update (last_team_id, last_board_id, mini_window_enabled, google_calendar_linked)
  on public.user_settings to authenticated;

grant update (name, description) on public.teams to authenticated;

grant insert (team_id, name) on public.boards to authenticated;
grant update (name) on public.boards to authenticated;

grant insert (
  team_id, board_id, title, description,
  start_at, start_has_time, due_at, due_has_time,
  priority, pos_x, pos_y, color, size
) on public.tasks to authenticated;
grant update (
  title, description,
  start_at, start_has_time, due_at, due_has_time,
  priority, status, pos_x, pos_y, color, size, latest_comment
) on public.tasks to authenticated;

grant insert (task_id, user_id), delete on public.task_members to authenticated;

grant update (is_read) on public.notifications to authenticated;

-- -------------------------------------------------------------
-- profiles：自分＋同じチームの（過去を含む）メンバー
-- -------------------------------------------------------------
create policy "profiles_select_self_or_teammate" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or private.shares_team_with(id));

create policy "profiles_update_self" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- -------------------------------------------------------------
-- user_settings：自分のみ。前回チーム・ボードは所属しているものだけ保存できる
-- -------------------------------------------------------------
create policy "user_settings_select_self" on public.user_settings
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "user_settings_insert_self" on public.user_settings
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (last_team_id is null or private.is_team_member(last_team_id))
    and (last_board_id is null or exists (
      select 1 from public.boards b
      where b.board_id = last_board_id and private.is_team_member(b.team_id)
    ))
  );

create policy "user_settings_update_self" on public.user_settings
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (
    user_id = (select auth.uid())
    and (last_team_id is null or private.is_team_member(last_team_id))
    and (last_board_id is null or exists (
      select 1 from public.boards b
      where b.board_id = last_board_id and private.is_team_member(b.team_id)
    ))
  );

-- -------------------------------------------------------------
-- teams：メンバーが閲覧、owner だけ編集（作成・削除は RPC）
-- -------------------------------------------------------------
create policy "teams_select_member" on public.teams
  for select to authenticated
  using (private.is_team_member(team_id));

create policy "teams_update_owner" on public.teams
  for update to authenticated
  using (owner_user_id = (select auth.uid()) and deleted_at is null)
  with check (owner_user_id = (select auth.uid()));

-- -------------------------------------------------------------
-- team_members：同じチームのメンバーが閲覧（追加・変更は RPC）
-- -------------------------------------------------------------
create policy "team_members_select_member" on public.team_members
  for select to authenticated
  using (private.is_team_member(team_id));

-- -------------------------------------------------------------
-- team_invites：ポリシーなし（= クライアントからは一切アクセス不可）
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- boards：メンバーが閲覧、リーダーが作成・名前変更
-- -------------------------------------------------------------
create policy "boards_select_member" on public.boards
  for select to authenticated
  using (private.is_team_member(team_id));

create policy "boards_insert_leader" on public.boards
  for insert to authenticated
  with check (private.is_team_leader(team_id) and created_by = (select auth.uid()));

create policy "boards_update_leader" on public.boards
  for update to authenticated
  using (private.is_team_leader(team_id))
  with check (private.is_team_leader(team_id));

-- -------------------------------------------------------------
-- tasks：メンバーが閲覧・作成。編集は「操作できる人」（private.can_edit_task）
-- 削除・復元・完了・承認は RPC 経由。
-- -------------------------------------------------------------
create policy "tasks_select_member" on public.tasks
  for select to authenticated
  using (private.is_team_member(team_id));

create policy "tasks_insert_member" on public.tasks
  for insert to authenticated
  with check (private.is_team_member(team_id) and created_by = (select auth.uid()));

create policy "tasks_update_editor" on public.tasks
  for update to authenticated
  using (private.can_edit_task(task_id))
  with check (private.is_team_member(team_id));

-- -------------------------------------------------------------
-- task_members：メンバーが閲覧。追加・削除は「操作できる人」
-- -------------------------------------------------------------
create policy "task_members_select_member" on public.task_members
  for select to authenticated
  using (private.is_team_member(private.task_team_id(task_id)));

create policy "task_members_insert_editor" on public.task_members
  for insert to authenticated
  with check (private.can_edit_task(task_id));

create policy "task_members_delete_editor" on public.task_members
  for delete to authenticated
  using (private.can_edit_task(task_id));

-- -------------------------------------------------------------
-- task_status_history：メンバーが閲覧のみ（記録はトリガー）
-- -------------------------------------------------------------
create policy "task_status_history_select_member" on public.task_status_history
  for select to authenticated
  using (private.is_team_member(team_id));

-- -------------------------------------------------------------
-- notifications：自分宛てのみ閲覧・既読化（作成はトリガー／RPC）
-- -------------------------------------------------------------
create policy "notifications_select_own" on public.notifications
  for select to authenticated
  using (recipient_user_id = (select auth.uid()));

create policy "notifications_update_own" on public.notifications
  for update to authenticated
  using (recipient_user_id = (select auth.uid()))
  with check (recipient_user_id = (select auth.uid()));
