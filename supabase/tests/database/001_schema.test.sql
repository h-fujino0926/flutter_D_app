-- =============================================================
-- スキーマ全体のチェック
--   ・public の全テーブルで RLS が有効
--   ・未ログイン（anon）には何の権限もない
--   ・team_invites はログインユーザーからも読めない
-- 実行：supabase test db
-- =============================================================
begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

select is(
  (select count(*) from pg_tables where schemaname = 'public' and not rowsecurity),
  0::bigint,
  'public の全テーブルで RLS が有効になっている'
);

select is(
  (select count(*) from information_schema.role_table_grants
   where table_schema = 'public' and grantee = 'anon'),
  0::bigint,
  'anon（未ログイン）にはテーブル権限が1つもない'
);

select is(
  (select count(*) from information_schema.role_table_grants
   where table_schema = 'public' and table_name = 'team_invites' and grantee = 'authenticated'),
  0::bigint,
  'team_invites は authenticated にも権限がない'
);

select ok(
  not has_function_privilege('anon', 'public.join_team(text, text)', 'execute'),
  'anon は RPC（join_team）を実行できない'
);

select ok(
  not has_column_privilege('authenticated', 'public.tasks', 'deleted_at', 'update'),
  'tasks.deleted_at はクライアントから直接 UPDATE できない（RPC 経由のみ）'
);

select * from finish();
rollback;
