-- =============================================================
-- Realtime（postgres_changes）の対象テーブル
--
-- RLS が有効なテーブルの変更は「その行を SELECT できるユーザー」にだけ配信される。
-- 注意：DELETE イベントは RLS で絞り込まれず、主キーだけが全購読者に届く。
--       このアプリで物理 DELETE するのは task_members だけなので、
--       クライアントは「自分が読み込み済みの task_member_id」以外の DELETE を無視すること。
-- =============================================================

alter publication supabase_realtime add table
  public.tasks,
  public.task_members,
  public.notifications,
  public.team_members,
  public.boards,
  public.teams;
