-- =============================================================
-- 開発用のテストデータ（supabase start / supabase db reset のときに投入される）
-- ※ローカル専用。本番（クラウド）には入れないこと。
--
-- テストユーザー（パスワードは全員 password123）
--   alice@example.com : チームA の作成者（owner / leader）
--   bob@example.com   : チームA の一般メンバー
--   carol@example.com : チームB の作成者（チームA には入っていない ＝ 分離の確認用）
-- =============================================================

-- -------------------------------------------------------------
-- ユーザー（auth.users と auth.identities）
-- profiles / user_settings はトリガーで自動作成される
-- -------------------------------------------------------------
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token
)
select
  '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated', u.email,
  extensions.crypt('password123', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('display_name', u.display_name), now(), now(),
  '', '', '', '', '', '', '', ''
from (values
  ('11111111-1111-1111-1111-111111111111'::uuid, 'alice@example.com', 'ありす'),
  ('22222222-2222-2222-2222-222222222222'::uuid, 'bob@example.com',   'ぼぶ'),
  ('33333333-3333-3333-3333-333333333333'::uuid, 'carol@example.com', 'きゃろる')
) as u(id, email, display_name);

insert into auth.identities (
  id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(), u.id, u.id::text,
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  'email', now(), now(), now()
from auth.users u
where u.email in ('alice@example.com', 'bob@example.com', 'carol@example.com');

update public.profiles set icon_color = '#2A9D8F' where email = 'bob@example.com';
update public.profiles set icon_color = '#E76F51' where email = 'carol@example.com';

-- -------------------------------------------------------------
-- チーム（RPC を本人として呼んで作る：初期ボード「メイン」も自動作成される）
-- -------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', false);
select public.create_team('チームA（開発用）', 'alice と bob のチーム');

select set_config('request.jwt.claims', '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}', false);
select public.create_team('チームB（開発用）', 'carol だけのチーム');

select set_config('request.jwt.claims', '', false);

-- bob をチームA に一般メンバーとして追加
insert into public.team_members (team_id, user_id, role)
select t.team_id, '22222222-2222-2222-2222-222222222222', 'member'
from public.teams t where t.name = 'チームA（開発用）';

-- チームA に「UI班」ボードを追加
insert into public.boards (team_id, name, created_by)
select t.team_id, 'UI班', '11111111-1111-1111-1111-111111111111'
from public.teams t where t.name = 'チームA（開発用）';

-- -------------------------------------------------------------
-- 付箋
-- -------------------------------------------------------------
insert into public.tasks (
  team_id, board_id, title, description, due_at, due_has_time,
  priority, status, pos_x, pos_y, color, created_by
)
select b.team_id, b.board_id, v.title, v.description,
       v.due_at, v.due_has_time, v.priority::public.task_priority,
       v.status::public.task_status, v.pos_x, v.pos_y, v.color, v.created_by
from public.boards b
join public.teams t on t.team_id = b.team_id
cross join (values
  ('ログイン画面のデザイン', 'Figma で作る', now() + interval '3 days', false, 'high', 'todo', 40.0, 40.0, '#FFF59D', '11111111-1111-1111-1111-111111111111'::uuid),
  ('DB のマイグレーション確認', null, now() + interval '20 hours', true, 'medium', 'in_progress', 280.0, 60.0, '#B3E5FC', '11111111-1111-1111-1111-111111111111'::uuid),
  ('README を書く', '無料プランの注意も書く', now() - interval '1 day', false, 'low', 'todo', 520.0, 80.0, '#C8E6C9', '22222222-2222-2222-2222-222222222222'::uuid),
  ('担当者なしのタスク', null, null, false, 'medium', 'todo', 120.0, 280.0, '#F8BBD0', '22222222-2222-2222-2222-222222222222'::uuid)
) as v(title, description, due_at, due_has_time, priority, status, pos_x, pos_y, color, created_by)
where t.name = 'チームA（開発用）' and b.name = 'メイン';

insert into public.tasks (team_id, board_id, title, created_by, pos_x, pos_y)
select b.team_id, b.board_id, 'チームB の秘密タスク', '33333333-3333-3333-3333-333333333333', 40, 40
from public.boards b
join public.teams t on t.team_id = b.team_id
where t.name = 'チームB（開発用）';

-- 担当者
insert into public.task_members (task_id, user_id)
select t.task_id, v.user_id
from public.tasks t
join (values
  ('ログイン画面のデザイン', '22222222-2222-2222-2222-222222222222'::uuid),
  ('DB のマイグレーション確認', '11111111-1111-1111-1111-111111111111'::uuid),
  ('DB のマイグレーション確認', '22222222-2222-2222-2222-222222222222'::uuid),
  ('README を書く', '22222222-2222-2222-2222-222222222222'::uuid)
) as v(title, user_id) on v.title = t.title;

-- 前回のチーム・ボード（ログイン後にチームA のメインボードが開く）
update public.user_settings s
set last_team_id = b.team_id, last_board_id = b.board_id
from public.boards b
join public.teams t on t.team_id = b.team_id
where t.name = 'チームA（開発用）' and b.name = 'メイン'
  and s.user_id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
