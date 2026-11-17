-- =============================================================
-- 列挙型（enum）
-- =============================================================

-- チーム内のロール
create type public.team_role as enum ('leader', 'member');

-- タスクの状態（設計書の done / completed の混在は done に統一）
create type public.task_status as enum ('todo', 'in_progress', 'done');

-- 優先度（画面表示は 高・中・低）
create type public.task_priority as enum ('high', 'medium', 'low');

-- 付箋のサイズ
create type public.task_size as enum ('S', 'M', 'L');

-- 通知の種類
create type public.notification_type as enum (
  'task_completed',   -- タスクが完了した（リーダー全員と作成者へ）
  'task_returned',    -- 差し戻された（完了した人へ）
  'task_approved',    -- 承認された（完了した人へ）
  'message_updated',  -- 一言メッセージが更新された（担当者と作成者へ）
  'task_assigned'     -- 担当者に割り当てられた
);
