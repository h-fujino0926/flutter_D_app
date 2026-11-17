-- =============================================================
-- 付箋の操作権限・完了・Undo・レビュー・通知
-- 登場人物（すべて同じチーム）：
--   k_leader : leader
--   k_maker  : member。付箋を作って k_doer に割り当てる
--   k_doer   : member。担当者
-- =============================================================
begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

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
create function tests.task_id() returns bigint language sql as $$
  select task_id from public.tasks where title = 'テスト付箋';
$$;
grant execute on function tests.task_id() to authenticated;

insert into auth.users (id, email, raw_user_meta_data) values
  ('cccccccc-0000-0000-0000-000000000001', 'k_leader@test.local', '{"display_name":"リーダー"}'),
  ('cccccccc-0000-0000-0000-000000000002', 'k_maker@test.local',  '{"display_name":"作成者"}'),
  ('cccccccc-0000-0000-0000-000000000003', 'k_doer@test.local',   '{"display_name":"担当者"}');

select tests.login_as('cccccccc-0000-0000-0000-000000000001');
select public.create_team('付箋テストチーム', null);
select tests.logout();

insert into public.team_members (team_id, user_id, role)
select team_id, u.id, 'member'
from public.teams, (values
  ('cccccccc-0000-0000-0000-000000000002'::uuid),
  ('cccccccc-0000-0000-0000-000000000003'::uuid)) as u(id)
where name = '付箋テストチーム';

-- ---- 1. member が付箋を作成し、担当者を割り当てられる ----
select tests.login_as('cccccccc-0000-0000-0000-000000000002');
select lives_ok(
  $$insert into public.tasks (team_id, board_id, title)
    select b.team_id, b.board_id, 'テスト付箋'
    from public.boards b join public.teams t using (team_id)
    where t.name = '付箋テストチーム'$$,
  'member は付箋を作成できる');
select lives_ok(
  $$insert into public.task_members (task_id, user_id)
    values (tests.task_id(), 'cccccccc-0000-0000-0000-000000000003')$$,
  '担当者がいない付箋は、作成者が担当者を割り当てられる');

-- ---- 2. 担当者を他人にした後は、作成者は操作できない（C1） ----
select is(
  tests.affected($$update public.tasks set title = '書き換え' where task_id = tests.task_id()$$),
  0::bigint, '作成者でも担当者でなければ付箋を編集できない');
select tests.logout();

-- ---- 3. 担当者には割り当て通知が届く ----
select is(
  (select count(*) from public.notifications
   where recipient_user_id = 'cccccccc-0000-0000-0000-000000000003' and type = 'task_assigned'),
  1::bigint, '担当者に task_assigned 通知が届く');

-- ---- 4〜6. 担当者の操作 ----
select tests.login_as('cccccccc-0000-0000-0000-000000000003');
select is(
  tests.affected($$update public.tasks set status = 'in_progress', pos_x = 100 where task_id = tests.task_id()$$),
  1::bigint, '担当者は付箋を移動・ステータス変更できる');
select throws_ok(
  $$update public.tasks set status = 'done' where task_id = tests.task_id()$$,
  'P0001', 'FORBIDDEN', '直接 UPDATE で done にはできない（RPC 経由のみ）');
select throws_ok(
  $$update public.tasks set deleted_at = now() where task_id = tests.task_id()$$,
  '42501', null, 'deleted_at は直接 UPDATE できない');

-- ---- 7〜9. 完了 → 通知 → Undo ----
select lives_ok($$select public.complete_task(tests.task_id())$$, '担当者は完了できる');
select tests.logout();

select is(
  (select array_agg(recipient_user_id order by recipient_user_id)
   from public.notifications where type = 'task_completed' and task_id = tests.task_id()),
  array['cccccccc-0000-0000-0000-000000000001', 'cccccccc-0000-0000-0000-000000000002']::uuid[],
  '完了通知はリーダーと作成者に届き、完了した本人には届かない');

select tests.login_as('cccccccc-0000-0000-0000-000000000003');
select is(public.undo_complete(tests.task_id()), 'in_progress'::public.task_status,
  'Undo すると完了前のステータス（履歴から取得）に戻る');
select public.complete_task(tests.task_id());
select tests.logout();

-- ---- 10〜13. レビュー ----
select tests.login_as('cccccccc-0000-0000-0000-000000000002');
select throws_ok(
  $$select public.review_task(tests.task_id(), true, null)$$,
  'P0001', 'FORBIDDEN', 'member はレビューできない');
select tests.logout();

select tests.login_as('cccccccc-0000-0000-0000-000000000001');
select throws_ok(
  $$select public.review_task(tests.task_id(), false, '  ')$$,
  'P0001', 'COMMENT_REQUIRED', '差し戻しにはメッセージが必要');
select lives_ok(
  $$select public.review_task(tests.task_id(), false, 'テストが足りません')$$,
  'leader はメッセージ付きで差し戻せる');
select tests.logout();

select ok(
  (select status = 'in_progress' and returned_at is not null and completed_at is null
          and latest_comment = 'テストが足りません'
   from public.tasks where task_id = tests.task_id()),
  '差し戻すと進行中に戻り、差し戻し中になり、一言メッセージが上書きされる');

-- ---- 14〜15. 差し戻しの履歴と通知 ----
select is(
  (select comment from public.task_status_history
   where task_id = tests.task_id() order by history_id desc limit 1),
  'テストが足りません', 'ステータス履歴に差し戻しコメントが残る');
select is(
  (select count(*) from public.notifications
   where recipient_user_id = 'cccccccc-0000-0000-0000-000000000003' and type = 'task_returned'),
  1::bigint, '差し戻し通知は完了した人に届く');

-- ---- 16. 担当者のマイタスク ----
select tests.login_as('cccccccc-0000-0000-0000-000000000003');
select is(
  (select count(*) from public.get_my_tasks() where title = 'テスト付箋'),
  1::bigint, 'get_my_tasks に自分の担当タスクが出る');

-- ---- 17. 作成者でもリーダーでもない担当者は削除できない ----
select throws_ok(
  $$select public.delete_task(tests.task_id())$$,
  'P0001', 'FORBIDDEN', '担当者でも作成者・リーダーでなければ削除できない');
select tests.logout();

-- ---- 18〜19. 担当者が自分を外して別の人に渡せる（アプリは「追加 → 削除」の順で行う） ----
select tests.login_as('cccccccc-0000-0000-0000-000000000003');
select lives_ok(
  $$insert into public.task_members (task_id, user_id)
    values (tests.task_id(), 'cccccccc-0000-0000-0000-000000000002')$$,
  '担当者は別のメンバーを担当者に追加できる');
select lives_ok(
  $$delete from public.task_members
    where task_id = tests.task_id() and user_id = 'cccccccc-0000-0000-0000-000000000003'$$,
  'その後、自分を担当者から外せる');
select tests.logout();

select * from finish();
rollback;
