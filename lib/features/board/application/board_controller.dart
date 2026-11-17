import 'dart:async';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/utils/throttle.dart';
import '../../task/application/my_tasks_controller.dart';
import '../../task/data/task_repository.dart';
import '../domain/canvas_layout.dart';

part 'board_controller.g.dart';

/// 他の人がドラッグ中の付箋の位置（broadcast で受け取る。DB は通らない）
class RemoteDrag {
  const RemoteDrag({required this.position, required this.userId, required this.at});
  final Offset position;
  final String userId;
  final DateTime at;
}

/// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
///
/// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
///   ・presence：今このボードを見ている人
/// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。
@riverpod
class BoardTasks extends _$BoardTasks {
  late int _boardId;
  RealtimeChannel? _channel;
  final _dragThrottler = Throttler(const Duration(milliseconds: 100));
  bool _needsResync = false;

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  Future<Map<int, Task>> build(int boardId) async {
    _boardId = boardId;
    final client = ref.watch(supabaseProvider);
    final uid = ref.watch(currentUserIdProvider);

    _subscribe(client, uid);
    ref.onDispose(() {
      _dragThrottler.cancel();
      final channel = _channel;
      _channel = null;
      if (channel != null) unawaited(client.removeChannel(channel));
    });

    return _fetchAll();
  }

  Future<Map<int, Task>> _fetchAll() async {
    final tasks = await _repo.fetchBoardTasks(_boardId);
    return {for (final t in tasks) t.taskId: t};
  }

  Map<int, Task> get _current => state.value ?? const {};

  // ---------------- Realtime ----------------

  void _subscribe(SupabaseClient client, String? uid) {
    final channel = client.channel(
      'board:$_boardId',
      opts: RealtimeChannelConfig(key: uid ?? ''),
    );
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'board_id',
            value: _boardId,
          ),
          callback: _onTaskChanged,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'task_members',
          callback: _onTaskMemberChanged,
        )
        .onBroadcast(event: 'drag', callback: (payload) => _onRemoteDrag(payload, uid))
        .onPresenceSync((_) => _onPresenceSync(channel))
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            if (uid != null) await channel.track({'user_id': uid});
            // 切断から復帰したら、取りこぼしがないよう全件取り直す（7.3 の 7）
            if (_needsResync) {
              _needsResync = false;
              await refreshAll();
            }
          } else {
            _needsResync = true;
          }
        });
    _channel = channel;
  }

  void _onTaskChanged(PostgresChangePayload payload) {
    if (payload.eventType == PostgresChangeEvent.delete) {
      final id = (payload.oldRecord['task_id'] as num?)?.toInt();
      if (id != null) removeLocal(id);
      return;
    }
    final record = Map<String, dynamic>.from(payload.newRecord);
    final id = (record['task_id'] as num).toInt();
    // tasks の変更には担当者が含まれないので、手元の担当者を引き継ぐ
    final existing = _current[id];
    record['task_members'] = [
      for (final a in existing?.assignees ?? const <TaskAssignee>[])
        {'task_member_id': a.taskMemberId, 'user_id': a.userId},
    ];
    final task = Task.fromJson(record);
    ref.read(remoteDragsProvider(_boardId).notifier).remove(id);
    if (task.isDeleted || task.status == TaskStatus.done) {
      removeLocal(id);
    } else {
      upsertLocal(task);
    }
    ref.read(myTasksProvider.notifier).refreshSoon();
  }

  void _onTaskMemberChanged(PostgresChangePayload payload) {
    // DELETE は RLS で絞り込まれず主キーしか来ないので、手元にある担当者だけ対象にする
    if (payload.eventType == PostgresChangeEvent.delete) {
      final memberId = (payload.oldRecord['task_member_id'] as num?)?.toInt();
      for (final t in _current.values) {
        if (t.assignees.any((a) => a.taskMemberId == memberId)) {
          unawaited(refetchTask(t.taskId));
          break;
        }
      }
    } else {
      final taskId = (payload.newRecord['task_id'] as num?)?.toInt();
      if (taskId != null && _current.containsKey(taskId)) {
        unawaited(refetchTask(taskId));
      }
    }
    ref.read(myTasksProvider.notifier).refreshSoon();
  }

  void _onRemoteDrag(Map<String, dynamic> raw, String? myUid) {
    final data = raw['payload'] is Map ? Map<String, dynamic>.from(raw['payload'] as Map) : raw;
    final userId = data['user_id'] as String?;
    if (userId == null || userId == myUid) return;
    ref
        .read(remoteDragsProvider(_boardId).notifier)
        .put(
          (data['task_id'] as num).toInt(),
          RemoteDrag(
            position: Offset((data['x'] as num).toDouble(), (data['y'] as num).toDouble()),
            userId: userId,
            at: DateTime.now(),
          ),
        );
  }

  void _onPresenceSync(RealtimeChannel channel) {
    final ids = <String>{};
    for (final state in channel.presenceState()) {
      for (final p in state.presences) {
        final id = p.payload['user_id'];
        if (id is String) ids.add(id);
      }
    }
    ref.read(boardViewersProvider(_boardId).notifier).set(ids);
  }

  // ---------------- 手元の状態の更新 ----------------

  void upsertLocal(Task task) {
    state = AsyncData({..._current, task.taskId: task});
  }

  void removeLocal(int taskId) {
    if (!_current.containsKey(taskId)) return;
    state = AsyncData({..._current}..remove(taskId));
  }

  Future<void> refreshAll() async {
    state = AsyncData(await _fetchAll());
  }

  Future<void> refetchTask(int taskId) async {
    final task = await _repo.fetchTask(taskId);
    if (task == null || task.isDeleted || task.status == TaskStatus.done || task.boardId != _boardId) {
      removeLocal(taskId);
    } else {
      upsertLocal(task);
    }
  }

  // ---------------- 操作 ----------------

  /// ドラッグ中の位置を他のメンバーへ送る（100ms に1回まで。DB には書かない）
  void sendDrag(int taskId, Offset position, String userId) {
    _dragThrottler.run(() {
      unawaited(
        _channel?.sendBroadcastMessage(
          event: 'drag',
          payload: {'task_id': taskId, 'x': position.dx, 'y': position.dy, 'user_id': userId},
        ),
      );
    });
  }

  /// ドロップ時に位置を確定する（DB への書き込みはここで1回だけ）
  Future<void> moveTask(int taskId, Offset position) async {
    final task = _current[taskId];
    if (task == null) return;
    upsertLocal(task.copyWith(posX: position.dx, posY: position.dy)); // 楽観的更新
    try {
      await _repo.move(taskId, position.dx, position.dy);
    } catch (_) {
      await refetchTask(taskId);
      rethrow;
    }
  }

  Future<void> setStatus(int taskId, TaskStatus status) async {
    final task = _current[taskId];
    if (task == null) return;
    upsertLocal(task.copyWith(status: status));
    try {
      await _repo.setStatus(taskId, status);
    } catch (_) {
      await refetchTask(taskId);
      rethrow;
    }
  }

  /// 完了（アニメーションの後に呼ぶ）。ボードからはすぐ消す。
  Future<void> completeTask(int taskId) async {
    final task = _current[taskId];
    removeLocal(taskId);
    ref.read(myTasksProvider.notifier).removeLocal(taskId);
    try {
      await _repo.complete(taskId);
    } catch (_) {
      if (task != null) upsertLocal(task);
      ref.read(myTasksProvider.notifier).refreshSoon();
      rethrow;
    }
  }

  Future<void> undoComplete(int taskId) async {
    await _repo.undoComplete(taskId);
    await refetchTask(taskId);
    ref.read(myTasksProvider.notifier).refreshSoon();
  }

  /// 新しい付箋を「空いている位置」に作る
  Future<Task> createTask({required int teamId, required TaskDraft draft}) async {
    final pos = findFreePosition(_current.values, size: draft.size);
    final task = await _repo.createTask(
      teamId: teamId,
      boardId: _boardId,
      draft: draft,
      posX: pos.dx,
      posY: pos.dy,
    );
    upsertLocal(task);
    ref.read(myTasksProvider.notifier).refreshSoon();
    return task;
  }
}

/// 他の人がドラッグ中の付箋（task_id → 位置）
@riverpod
class RemoteDrags extends _$RemoteDrags {
  Timer? _cleanup;

  @override
  Map<int, RemoteDrag> build(int boardId) {
    ref.onDispose(() => _cleanup?.cancel());
    return const {};
  }

  void put(int taskId, RemoteDrag drag) {
    state = {...state, taskId: drag};
    // 2秒以上更新がないもの（相手の通信が切れた等）は消す
    _cleanup?.cancel();
    _cleanup = Timer(const Duration(seconds: 2), () {
      final now = DateTime.now();
      state = {
        for (final e in state.entries)
          if (now.difference(e.value.at) < const Duration(seconds: 2)) e.key: e.value,
      };
    });
  }

  void remove(int taskId) {
    if (!state.containsKey(taskId)) return;
    state = {...state}..remove(taskId);
  }
}

/// 今このボードを見ているメンバー（presence）
@riverpod
class BoardViewers extends _$BoardViewers {
  @override
  Set<String> build(int boardId) => const {};

  void set(Set<String> ids) => state = ids;
}
