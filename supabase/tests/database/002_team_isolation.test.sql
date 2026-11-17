-- =============================================================
-- チーム間のデータ分離と、leader / member の権限
-- 登場人物：
--   t_alice : チームT の owner（leader）
--   t_bob   : チームT の member（招待で参加）
--   t_carol : チームU の owner。チームT とは無関係
-- =============================================================
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

-- ---- テスト用ヘルパー（ロールバックで消える） ----
create schema tests;
grant usage on schema tests to authenticated;
create function tests.login_as(p_user uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
end;
$$;
create function tests.affected(p_sql text) returns bigint language plpgsql as $f$
declare n bigint;
begin
  execute p_sql;
  get diagnostics n = row_count;
  return n;
end;
$f$;
create function tests.logout() returns void language plpgsql as $$
begin
  execute 'reset role';
  perform set_config('request.jwt.claims', '', true);
end;
$$;

-- ---- 準備 ----
insert into auth.users (id, email, raw_user_meta_data) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 't_alice@test.local', '{"display_name":"テストありす"}'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 't_bob@test.local',   '{"display_name":"テストぼぶ"}'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 't_carol@test.local', '{"display_name":"テストきゃろる"}');

select tests.login_as('aaaaaaaa-0000-0000-0000-000000000001');
select public.create_team('テストチームT', null);
create temp table t_invite on commit drop as
  select public.create_invite(
    (select team_id from public.teams where name = 'テストチームT'), 0
  ) as r;
insert into public.tasks (team_id, board_id, title)
  select b.team_id, b.board_id, 'Tのタスク'
  from public.boards b join public.teams t using (team_id)
  where t.name = 'テストチームT';
select tests.logout();

select tests.login_as('aaaaaaaa-0000-0000-0000-000000000003');
select public.create_team('テストチームU', null);
select tests.logout();

-- ---- 1. 新規登録でプロフィールが自動作成される ----
select is(
  (select display_name from public.profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  'テストありす',
  'auth.users 追加時に profiles が作られ、表示名が入る'
);

-- ---- 2〜4. 他チームのデータは見えない ----
select tests.login_as('aaaaaaaa-0000-0000-0000-000000000003');
select is(
  (select count(*) from public.teams where name = 'テストチームT'),
  0::bigint, 'carol にはチームT が見えない');
select is(
  (select count(*) from public.tasks where title = 'Tのタスク'),
  0::bigint, 'carol にはチームT の付箋が見えない');
select is(
  (select count(*) from public.profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  0::bigint, 'carol には無関係な alice のプロフィールが見えない');
select tests.logout();

-- ---- 5. 招待テーブルは leader でも読めない ----
select tests.login_as('aaaaaaaa-0000-0000-0000-000000000001');
select throws_ok(
  'select * from public.team_invites',
  '42501', null,
  'team_invites は leader でも直接 SELECT できない');
select tests.logout();

-- ---- 6. 招待で参加できる ----
select tests.login_as('aaaaaaaa-0000-0000-0000-000000000002');
select is(
  (select (public.join_team(r ->> 'token', r ->> 'passcode')) ->> 'ok' from t_invite),
  'true', 'bob は正しいパスコードでチームT に参加できる');
select is(
  (select count(*) from public.tasks where title = 'Tのタスク'),
  1::bigint, '参加後の bob にはチームT の付箋が見える');

-- ---- 7〜10. member は leader の操作ができない ----
select throws_ok(
  $$select public.create_invite((select team_id from public.teams where name = 'テストチームT'), 0)$$,
  'P0001', 'FORBIDDEN', 'member は招待を発行できない');
select throws_ok(
  $$insert into public.boards (team_id, name)
    select team_id, 'bobのボード' from public.teams where name = 'テストチームT'$$,
  '42501', null, 'member はボードを作成できない');
select throws_ok(
  $$select public.change_member_role(
      (select team_id from public.teams where name = 'テストチームT'),
      'aaaaaaaa-0000-0000-0000-000000000002', 'leader')$$,
  'P0001', 'FORBIDDEN', 'member は自分を leader にできない');
select is(
  tests.affected($$update public.teams set name = '乗っ取り' where name = 'テストチームT'$$),
  0::bigint, 'owner 以外はチーム情報を編集できない');
select tests.logout();

-- ---- 11〜12. owner と leader の制約 ----
select tests.login_as('aaaaaaaa-0000-0000-0000-000000000001');
select throws_ok(
  $$select public.leave_team((select team_id from public.teams where name = 'テストチームT'))$$,
  'P0001', 'OWNER_CANNOT_LEAVE', 'owner はチームを退出できない');
select throws_ok(
  $$select public.change_member_role(
      (select team_id from public.teams where name = 'テストチームT'),
      'aaaaaaaa-0000-0000-0000-000000000001', 'member')$$,
  'P0001', 'OWNER_ROLE_LOCKED', 'owner のロールは変更できない');
select tests.logout();

-- ---- 13. member は退出できる ----
select tests.login_as('aaaaaaaa-0000-0000-0000-000000000002');
select lives_ok(
  $$select public.leave_team((select team_id from public.teams where name = 'テストチームT'))$$,
  'member は退出できる');
select tests.logout();

select * from finish();
rollback;
