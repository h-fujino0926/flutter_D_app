-- =============================================================
-- テーブル
--   ・ユーザーの主キーは auth.users.id（uuid）。それ以外は identity。
--   ・日時はすべて timestamptz。
--   ・論理削除は deleted_at / left_at / revoked_at に日時を入れる。
--   ・RLS の有効化とポリシーは 20261116000005 で行う。
-- =============================================================

-- -------------------------------------------------------------
-- profiles（設計書の user。パスワードは Supabase Auth が管理するので持たない）
-- -------------------------------------------------------------
create table public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  display_name  text not null check (char_length(display_name) between 1 and 20),
  -- 表示用のコピー。auth.users の email が変わったらトリガーで同期する。
  email         text not null unique,
  icon_color    text not null default '#F4A261'
                check (icon_color ~ '^#[0-9A-Fa-f]{6}$'),
  last_login_at timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
comment on table public.profiles is 'ユーザーのプロフィール（auth.users と 1対1）';

-- -------------------------------------------------------------
-- teams
-- -------------------------------------------------------------
create table public.teams (
  team_id       bigint generated always as identity primary key,
  name          text not null check (char_length(name) between 1 and 30),
  description   text check (char_length(description) <= 200),
  -- 作成者（owner）。owner は退出できず、ロールも変更できない（仮決定）。
  owner_user_id uuid not null references public.profiles (id),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
comment on table public.teams is 'チーム';

-- -------------------------------------------------------------
-- team_members（設計書の member）
-- -------------------------------------------------------------
create table public.team_members (
  team_member_id bigint generated always as identity primary key,
  team_id        bigint not null references public.teams (team_id),
  user_id        uuid not null references public.profiles (id),
  role           public.team_role not null default 'member',
  joined_at      timestamptz not null default now(),
  left_at        timestamptz,  -- 退出時に設定。再参加したら null に戻す
  unique (team_id, user_id)
);
create index team_members_user_id_idx on public.team_members (user_id);
comment on table public.team_members is 'チームの所属メンバー';

-- -------------------------------------------------------------
-- team_invites（設計書の team_invite）
-- クライアントからは一切読み書きさせない（RPC のみ）。
-- -------------------------------------------------------------
create table public.team_invites (
  invitation_id   bigint generated always as identity primary key,
  team_id         bigint not null references public.teams (team_id),
  token           text not null unique,  -- 招待URL用のランダム文字列
  passcode_hash   text not null,         -- 6桁パスコードの sha256（平文は保存しない）
  created_by      uuid not null references public.profiles (id),
  expires_at      timestamptz not null,  -- 発行 + 72時間
  max_uses        int not null default 0 check (max_uses >= 0),  -- 0 = 無制限
  used_count      int not null default 0,
  failed_attempts int not null default 0,  -- 5回で自動無効化
  revoked_at      timestamptz,
  created_at      timestamptz not null default now()
);
create index team_invites_team_id_idx on public.team_invites (team_id);
comment on table public.team_invites is 'チーム招待（URL＋パスコード）';

-- -------------------------------------------------------------
-- boards
-- 仮決定：ボード画面は「列なしの自由キャンバス」なので board_columns は作らない。
-- -------------------------------------------------------------
create table public.boards (
  board_id   bigint generated always as identity primary key,
  team_id    bigint not null references public.teams (team_id),
  name       text not null check (char_length(name) between 1 and 30),
  created_by uuid not null default auth.uid() references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- tasks から (board_id, team_id) の組で参照するための一意制約
  unique (board_id, team_id)
);
create index boards_team_id_idx on public.boards (team_id);
comment on table public.boards is 'チーム内のボード（用途別）';

-- -------------------------------------------------------------
-- user_settings（設計書の user_setting）
-- 「ログイン状態を保持するか」は端末ごとなので shared_preferences 側に持つ。
-- -------------------------------------------------------------
create table public.user_settings (
  user_id                uuid primary key references public.profiles (id) on delete cascade,
  last_team_id           bigint references public.teams (team_id) on delete set null,
  last_board_id          bigint references public.boards (board_id) on delete set null,
  mini_window_enabled    boolean not null default true,
  google_calendar_linked boolean not null default false,
  updated_at             timestamptz not null default now()
);
comment on table public.user_settings is 'ユーザーごとの設定（前回のチーム・ボードなど）';

-- -------------------------------------------------------------
-- tasks（付箋）
-- -------------------------------------------------------------
create table public.tasks (
  task_id           bigint generated always as identity primary key,
  team_id           bigint not null references public.teams (team_id),
  board_id          bigint not null,
  title             text not null check (char_length(title) between 1 and 50),
  description       text check (char_length(description) <= 1000),

  -- 開始・締切は時刻まで持つ。時刻を指定しなかった場合は *_has_time = false で、
  -- アプリ側で「その日の 23:59（日本時間）」を入れる（仮決定）。
  start_at          timestamptz,
  start_has_time    boolean not null default false,
  due_at            timestamptz,
  due_has_time      boolean not null default false,

  priority          public.task_priority not null default 'medium',
  status            public.task_status not null default 'todo',

  -- キャンバス上の論理座標（px）。キャンバスはスクロールできる固定サイズ（仮決定）。
  pos_x             double precision not null default 0,
  pos_y             double precision not null default 0,
  color             text not null default '#FFF59D' check (color ~ '^#[0-9A-Fa-f]{6}$'),
  size              public.task_size not null default 'M',

  -- 一言メッセージ（常に最新1件）。by / at はトリガーで自動設定する。
  latest_comment    text check (char_length(latest_comment) <= 100),
  latest_comment_by uuid references public.profiles (id),
  latest_comment_at timestamptz,

  created_by        uuid not null default auth.uid() references public.profiles (id),
  completed_at      timestamptz,
  completed_by      uuid references public.profiles (id),
  reviewed_at       timestamptz,  -- リーダーが承認した日時
  reviewed_by       uuid references public.profiles (id),
  returned_at       timestamptz,  -- 差し戻された日時（再度完了したらクリア）
  deleted_at        timestamptz,  -- ゴミ箱
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),

  -- ボードが同じチームのものであることを保証する
  foreign key (board_id, team_id) references public.boards (board_id, team_id),
  constraint tasks_start_before_due
    check (start_at is null or due_at is null or start_at <= due_at)
);
create index tasks_board_id_idx on public.tasks (board_id) where deleted_at is null;
create index tasks_team_id_idx on public.tasks (team_id);
comment on table public.tasks is '付箋（タスク）';

-- -------------------------------------------------------------
-- task_members（担当者。多対多）
-- 設計書では team_member_id 参照だったが、RLS を単純にするため user_id を参照する。
-- -------------------------------------------------------------
create table public.task_members (
  task_member_id bigint generated always as identity primary key,
  task_id        bigint not null references public.tasks (task_id) on delete cascade,
  user_id        uuid not null references public.profiles (id),
  assigned_at    timestamptz not null default now(),
  unique (task_id, user_id)
);
create index task_members_user_id_idx on public.task_members (user_id);
comment on table public.task_members is 'タスクの担当者';

-- -------------------------------------------------------------
-- task_status_history（ステータス変更履歴。トリガーで自動記録）
-- -------------------------------------------------------------
create table public.task_status_history (
  history_id  bigint generated always as identity primary key,
  task_id     bigint not null references public.tasks (task_id) on delete cascade,
  team_id     bigint not null references public.teams (team_id),  -- RLS 判定用
  user_id     uuid references public.profiles (id),               -- 操作した人
  from_status public.task_status not null,
  to_status   public.task_status not null,
  comment     text,  -- 差し戻し時のメッセージ
  created_at  timestamptz not null default now()
);
create index task_status_history_task_id_idx on public.task_status_history (task_id, created_at desc);
comment on table public.task_status_history is 'タスクのステータス変更履歴';

-- -------------------------------------------------------------
-- notifications
-- -------------------------------------------------------------
create table public.notifications (
  notification_id   bigint generated always as identity primary key,
  recipient_user_id uuid not null references public.profiles (id) on delete cascade,
  actor_user_id     uuid references public.profiles (id),
  team_id           bigint references public.teams (team_id),
  task_id           bigint references public.tasks (task_id) on delete cascade,
  type              public.notification_type not null,
  message           varchar(255) not null,
  is_read           boolean not null default false,
  created_at        timestamptz not null default now()
);
create index notifications_recipient_idx
  on public.notifications (recipient_user_id, created_at desc);
comment on table public.notifications is '通知（作成はトリガー／RPC のみ）';
