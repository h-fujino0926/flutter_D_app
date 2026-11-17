-- =============================================================
-- 招待（join_team）の判定
--   ・パスコードを間違えると failed_attempts が保存され、5回で無効化
--   ・期限切れ・使用上限・無効化済み
-- =============================================================
begin;
create extension if not exists pgtap with schema extensions;
select plan(8);

create schema tests;
grant usage on schema tests to authenticated;
create function tests.login_as(p_user uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
end;
$$;
create function tests.logout() returns void language plpgsql as $$
begin
  execute 'reset role';
  perform set_config('request.jwt.claims', '', true);
end;
$$;

insert into auth.users (id, email, raw_user_meta_data) values
  ('bbbbbbbb-0000-0000-0000-000000000001', 'i_leader@test.local', '{"display_name":"招待リーダー"}'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'i_guest@test.local',  '{"display_name":"ゲスト"}'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'i_guest2@test.local', '{"display_name":"ゲスト2"}');

select tests.login_as('bbbbbbbb-0000-0000-0000-000000000001');
select public.create_team('招待テストチーム', null);
create temp table inv on commit drop as
  select 'normal' as kind,
         public.create_invite((select team_id from public.teams where name = '招待テストチーム'), 0) as r
  union all
  select 'one_use',
         public.create_invite((select team_id from public.teams where name = '招待テストチーム'), 1);
select tests.logout();

-- ---- 1. パスコード間違い ----
select tests.login_as('bbbbbbbb-0000-0000-0000-000000000002');
select is(
  (select public.join_team(r ->> 'token', 'XXXXXX') ->> 'code' from inv where kind = 'normal'),
  'WRONG_PASSCODE', 'パスコードが違うと WRONG_PASSCODE');
select tests.logout();

-- ---- 2. 失敗回数が（例外で巻き戻らずに）保存されている ----
select is(
  (select failed_attempts from public.team_invites i
   join inv on i.token = inv.r ->> 'token' where inv.kind = 'normal'),
  1, '失敗回数が保存されている');

-- ---- 3. 5回失敗すると無効化される ----
select tests.login_as('bbbbbbbb-0000-0000-0000-000000000002');
select public.join_team(r ->> 'token', 'XXXXXX') from inv where kind = 'normal';
select public.join_team(r ->> 'token', 'XXXXXX') from inv where kind = 'normal';
select public.join_team(r ->> 'token', 'XXXXXX') from inv where kind = 'normal';
select public.join_team(r ->> 'token', 'XXXXXX') from inv where kind = 'normal';
select is(
  (select public.join_team(r ->> 'token', r ->> 'passcode') ->> 'code' from inv where kind = 'normal'),
  'INVITE_NOT_FOUND', '5回失敗した招待は正しいパスコードでも使えない');

-- ---- 4. 小文字で入力しても通る ＆ 使用上限 ----
select is(
  (select public.join_team(r ->> 'token', lower(r ->> 'passcode')) ->> 'ok' from inv where kind = 'one_use'),
  'true', 'パスコードは小文字で入力しても参加できる');
select tests.logout();

select tests.login_as('bbbbbbbb-0000-0000-0000-000000000003');
select is(
  (select public.join_team(r ->> 'token', r ->> 'passcode') ->> 'code' from inv where kind = 'one_use'),
  'INVITE_LIMIT', '使用回数1回の招待は2人目が使えない');
select tests.logout();

-- ---- 5. 期限切れ ----
update public.team_invites i set expires_at = now() - interval '1 minute', used_count = 0
from inv where i.token = inv.r ->> 'token' and inv.kind = 'one_use';
select tests.login_as('bbbbbbbb-0000-0000-0000-000000000003');
select is(
  (select public.join_team(r ->> 'token', r ->> 'passcode') ->> 'code' from inv where kind = 'one_use'),
  'INVITE_EXPIRED', '72時間を過ぎた招待は INVITE_EXPIRED');

-- ---- 6. 存在しない token ----
select is(
  public.join_team('no-such-token', 'ABCDEF') ->> 'code',
  'INVITE_NOT_FOUND', '存在しない招待は INVITE_NOT_FOUND');
select tests.logout();

-- ---- 7. パスコードは平文で保存されていない ----
select ok(
  (select bool_and(i.passcode_hash <> inv.r ->> 'passcode' and length(i.passcode_hash) = 64)
   from public.team_invites i join inv on i.token = inv.r ->> 'token'),
  'パスコードは sha256 のハッシュで保存されている');

select * from finish();
rollback;
