-- =============================================================
-- RLS 判定用のヘルパー関数
--
--   ・RLS の中で team_members を直接参照すると無限再帰になるため、
--     security definer の関数にして RLS を通さずに判定する。
--   ・API（PostgREST）に公開されない private スキーマに置く
--     （クライアントから rpc() で直接呼べないようにするため）。
--   ・security definer 関数には必ず set search_path = '' を付け、
--     テーブル名・関数名はスキーマ付きで書く。
-- =============================================================

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
-- RLS ポリシーは authenticated ロールで評価されるので、使用権限だけ与える
grant usage on schema private to authenticated;

-- 自分がそのチームに（退出せずに）所属しているか。削除済みチームは false。
create or replace function private.is_team_member(p_team_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members m
    join public.teams t on t.team_id = m.team_id
    where m.team_id = p_team_id
      and m.user_id = (select auth.uid())
      and m.left_at is null
      and t.deleted_at is null
  );
$$;

-- 自分がそのチームのリーダーか
create or replace function private.is_team_leader(p_team_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members m
    join public.teams t on t.team_id = m.team_id
    where m.team_id = p_team_id
      and m.user_id = (select auth.uid())
      and m.role = 'leader'
      and m.left_at is null
      and t.deleted_at is null
  );
$$;

-- 指定ユーザーがそのチームのアクティブなメンバーか（担当者の割り当てチェック用）
create or replace function private.is_active_member(p_team_id bigint, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members m
    where m.team_id = p_team_id
      and m.user_id = p_user_id
      and m.left_at is null
  );
$$;

-- 相手のプロフィールを見てよいか。
-- 仮決定（B15）：自分が今所属しているチームに、相手が「過去も含めて」所属していれば見られる。
-- （退出したメンバーが作成・担当した付箋のアイコンを表示するため）
create or replace function private.shares_team_with(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members me
    join public.team_members other on other.team_id = me.team_id
    join public.teams t on t.team_id = me.team_id
    where me.user_id = (select auth.uid())
      and me.left_at is null
      and t.deleted_at is null
      and other.user_id = p_user_id
  );
$$;

-- タスクが属するチームID（task_members の RLS 用）
create or replace function private.task_team_id(p_task_id bigint)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select t.team_id from public.tasks t where t.task_id = p_task_id;
$$;

-- タスクを操作（移動・編集・ステータス変更・一言メッセージ・担当者変更）してよいか。
-- 仮決定（C1 / E3）：
--   ・リーダー
--   ・そのタスクの担当者
--   ・担当者が1人もいないタスクは、作成者も操作できる
create or replace function private.can_edit_task(p_task_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.tasks t
    where t.task_id = p_task_id
      and private.is_team_member(t.team_id)
      and (
        private.is_team_leader(t.team_id)
        or exists (
          select 1 from public.task_members a
          where a.task_id = t.task_id and a.user_id = (select auth.uid())
        )
        or (
          t.created_by = (select auth.uid())
          and not exists (select 1 from public.task_members a where a.task_id = t.task_id)
        )
      )
  );
$$;

-- タスクを削除・ゴミ箱から復元してよいか。
-- 仮決定：リーダー、または「作成者かつ操作できる人」。
create or replace function private.can_delete_task(p_task_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.tasks t
    where t.task_id = p_task_id
      and private.is_team_member(t.team_id)
      and (
        private.is_team_leader(t.team_id)
        or (t.created_by = (select auth.uid()) and private.can_edit_task(t.task_id))
      )
  );
$$;

-- 6桁パスコードのハッシュ（大文字・小文字は区別しない）
create or replace function private.hash_passcode(p_passcode text)
returns text
language sql
immutable
set search_path = ''
as $$
  select encode(extensions.digest(upper(trim(p_passcode)), 'sha256'), 'hex');
$$;

-- 付箋を復元するとき、他の付箋と重ならない位置を探す（右下に少しずつずらす）
create or replace function private.find_free_position(
  p_board_id bigint,
  p_task_id bigint,
  p_x double precision,
  p_y double precision,
  out x double precision,
  out y double precision
)
language plpgsql
stable
set search_path = ''
as $$
begin
  x := p_x;
  y := p_y;
  for i in 1..20 loop
    exit when not exists (
      select 1
      from public.tasks o
      where o.board_id = p_board_id
        and o.task_id <> p_task_id
        and o.deleted_at is null
        and o.status <> 'done'
        and abs(o.pos_x - x) < 16
        and abs(o.pos_y - y) < 16
    );
    x := x + 24;
    y := y + 24;
  end loop;
end;
$$;

grant execute on all functions in schema private to authenticated;
