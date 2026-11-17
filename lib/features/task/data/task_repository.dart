import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/utils/date_utils.dart';

part 'task_repository.g.dart';

/// 付箋を取得するときの列（担当者を埋め込む）
const taskSelect = '*, task_members(task_member_id, user_id)';

/// 付箋の作成・編集で入力する内容
class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description,
    this.startAt,
    this.startHasTime = false,
    this.dueAt,
    this.dueHasTime = false,
    this.priority = TaskPriority.medium,
    this.color = '#FFF59D',
    this.size = TaskSize.m,
    this.assigneeIds = const [],
  });

  final String title;
  final String? description;
  final DateTime? startAt;
  final bool startHasTime;
  final DateTime? dueAt;
  final bool dueHasTime;
  final TaskPriority priority;
  final String color;
  final TaskSize size;
  final List<String> assigneeIds;

  /// DB に書く列（クライアントに UPDATE が許可されている列だけ）
  Map<String, dynamic> toColumns() => {
    'title': title.trim(),
    'description': (description?.trim().isEmpty ?? true) ? null : description!.trim(),
    'start_at': toDbTimestamp(startAt),
    'start_has_time': startHasTime,
    'due_at': toDbTimestamp(dueAt),
    'due_has_time': dueHasTime,
    'priority': priority.dbValue,
    'color': color,
    'size': size.dbValue,
  };
}

/// 付箋（tasks / task_members / task_status_history）の DB 操作。
class TaskRepository {
  TaskRepository(this._client);

  final SupabaseClient _client;

  // ---------------- 取得 ----------------

  /// ボード上の付箋（未削除・未完了）
  Future<List<Task>> fetchBoardTasks(int boardId) async {
    final rows = await _client
        .from('tasks')
        .select(taskSelect)
        .eq('board_id', boardId)
        .isFilter('deleted_at', null)
        .neq('status', TaskStatus.done.dbValue)
        .order('task_id');
    return rows.map(Task.fromJson).toList();
  }

  /// チームの締切付きの付箋（カレンダー用。未削除・未完了）
  Future<List<Task>> fetchTeamTasksWithDue(int teamId) async {
    final rows = await _client
        .from('tasks')
        .select(taskSelect)
        .eq('team_id', teamId)
        .isFilter('deleted_at', null)
        .neq('status', TaskStatus.done.dbValue)
        .not('due_at', 'is', null)
        .order('due_at');
    return rows.map(Task.fromJson).toList();
  }

  Future<Task?> fetchTask(int taskId) async {
    final row = await _client
        .from('tasks')
        .select(taskSelect)
        .eq('task_id', taskId)
        .maybeSingle();
    return row == null ? null : Task.fromJson(row);
  }

  /// ゴミ箱（削除済み）
  Future<List<Task>> fetchTrash(int teamId) async {
    final rows = await _client
        .from('tasks')
        .select(taskSelect)
        .eq('team_id', teamId)
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);
    return rows.map(Task.fromJson).toList();
  }

  /// 完了ログ（完了済み・未削除）
  Future<List<Task>> fetchCompleted(int teamId) async {
    final rows = await _client
        .from('tasks')
        .select(taskSelect)
        .eq('team_id', teamId)
        .eq('status', TaskStatus.done.dbValue)
        .isFilter('deleted_at', null)
        .order('completed_at', ascending: false);
    return rows.map(Task.fromJson).toList();
  }

  /// 検索（P1-02）：チーム内の全ボードの未削除の付箋が対象
  Future<List<Task>> search({
    required int teamId,
    String? keyword,
    String? assigneeId,
    TaskStatus? status,
    TaskPriority? priority,
  }) async {
    // 担当者で絞るときは task_members を inner join にする
    var query = _client
        .from('tasks')
        .select(
          assigneeId == null
              ? taskSelect
              : '*, task_members!inner(task_member_id, user_id)',
        )
        .eq('team_id', teamId)
        .isFilter('deleted_at', null);
    if (keyword != null && keyword.trim().isNotEmpty) {
      // ilike のワイルドカード文字はエスケープしておく
      final escaped = keyword.trim().replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
      query = query.ilike('title', '%$escaped%');
    }
    if (assigneeId != null) query = query.eq('task_members.user_id', assigneeId);
    if (status != null) query = query.eq('status', status.dbValue);
    if (priority != null) query = query.eq('priority', priority.dbValue);
    final rows = await query.order('due_at', nullsFirst: false).limit(100);
    return rows.map(Task.fromJson).toList();
  }

  /// 所属する全チームの自分の担当タスク（未完了）
  Future<List<MyTask>> fetchMyTasks() async {
    final rows = await _client.rpc<List<dynamic>>('get_my_tasks');
    return rows.cast<Map<String, dynamic>>().map(MyTask.fromJson).toList();
  }

  Future<List<StatusHistory>> fetchHistory(int taskId) async {
    final rows = await _client
        .from('task_status_history')
        .select()
        .eq('task_id', taskId)
        .order('created_at', ascending: false)
        .order('history_id', ascending: false);
    return rows.map(StatusHistory.fromJson).toList();
  }

  // ---------------- 作成・編集 ----------------

  Future<Task> createTask({
    required int teamId,
    required int boardId,
    required TaskDraft draft,
    required double posX,
    required double posY,
  }) async {
    final row = await _client
        .from('tasks')
        .insert({
          'team_id': teamId,
          'board_id': boardId,
          'pos_x': posX,
          'pos_y': posY,
          ...draft.toColumns(),
        })
        .select('task_id')
        .single();
    final taskId = (row['task_id'] as num).toInt();
    if (draft.assigneeIds.isNotEmpty) {
      await _client.from('task_members').insert([
        for (final uid in draft.assigneeIds) {'task_id': taskId, 'user_id': uid},
      ]);
    }
    return (await fetchTask(taskId))!;
  }

  Future<void> updateTask(int taskId, TaskDraft draft) =>
      _client.from('tasks').update(draft.toColumns()).eq('task_id', taskId);

  /// 担当者の差分を反映する。
  /// ※「増えた人を追加 → 外れた人を削除」の順にすること。
  ///   担当者が自分を外して別の人に渡す場合、先に自分を消すと操作権限がなくなり、
  ///   その後の追加が RLS で拒否されてしまうため。
  Future<void> setAssignees(Task task, List<String> newIds) async {
    final added = newIds.where((id) => !task.assigneeIds.contains(id)).toList();
    final removed = task.assignees.where((a) => !newIds.contains(a.userId)).toList();
    if (added.isNotEmpty) {
      await _client.from('task_members').insert([
        for (final uid in added) {'task_id': task.taskId, 'user_id': uid},
      ]);
    }
    if (removed.isNotEmpty) {
      await _client
          .from('task_members')
          .delete()
          .inFilter('task_member_id', [for (final a in removed) a.taskMemberId]);
    }
  }

  /// 位置の確定（ドロップ時に1回だけ呼ぶ）
  Future<void> move(int taskId, double x, double y) => _client
      .from('tasks')
      .update({'pos_x': x, 'pos_y': y})
      .eq('task_id', taskId);

  /// 未着手 ⇔ 進行中の切り替え（完了は complete を使う）
  Future<void> setStatus(int taskId, TaskStatus status) {
    assert(status != TaskStatus.done, '完了は complete() を使うこと');
    return _client.from('tasks').update({'status': status.dbValue}).eq('task_id', taskId);
  }

  /// 締切だけ変更（カレンダーでの D&D）
  Future<void> updateDue(int taskId, DateTime dueAt) => _client
      .from('tasks')
      .update({'due_at': toDbTimestamp(dueAt)})
      .eq('task_id', taskId);

  /// 一言メッセージの上書き（機能13）
  Future<void> updateComment(int taskId, String? comment) => _client
      .from('tasks')
      .update({'latest_comment': (comment?.trim().isEmpty ?? true) ? null : comment!.trim()})
      .eq('task_id', taskId);

  // ---------------- RPC ----------------

  Future<void> complete(int taskId) =>
      _client.rpc<void>('complete_task', params: {'p_task_id': taskId});

  Future<TaskStatus> undoComplete(int taskId) async {
    final res = await _client.rpc<String>('undo_complete', params: {'p_task_id': taskId});
    return res == 'in_progress' ? TaskStatus.inProgress : TaskStatus.todo;
  }

  Future<void> review(int taskId, {required bool approve, String? comment}) =>
      _client.rpc<void>(
        'review_task',
        params: {'p_task_id': taskId, 'p_approve': approve, 'p_comment': comment},
      );

  Future<void> delete(int taskId) =>
      _client.rpc<void>('delete_task', params: {'p_task_id': taskId});

  Future<void> restore(int taskId) =>
      _client.rpc<void>('restore_task', params: {'p_task_id': taskId});

  Future<void> restoreCompleted(int taskId) =>
      _client.rpc<void>('restore_completed_task', params: {'p_task_id': taskId});
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) => TaskRepository(ref.watch(supabaseProvider));
