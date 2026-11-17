import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/ui/user_avatar.dart';
import '../../../core/utils/date_utils.dart';
import '../../board/application/board_controller.dart';
import '../../team/application/team_providers.dart';
import '../application/my_tasks_controller.dart';
import '../application/task_providers.dart';
import '../data/task_repository.dart';
import 'task_actions.dart';
import 'widgets/task_form.dart';

/// P1-03 付箋詳細ダイアログ
///
/// 全項目の表示・編集、一言メッセージ、ステータス変更、
/// （リーダーのみ）承認／差し戻し、削除、ステータス履歴。
Future<void> showTaskDetailDialog(BuildContext context, {required int taskId}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _TaskDetailLoader(taskId: taskId),
  );
}

/// 付箋を読み込んでから詳細を表示する
class _TaskDetailLoader extends ConsumerStatefulWidget {
  const _TaskDetailLoader({required this.taskId});
  final int taskId;

  @override
  ConsumerState<_TaskDetailLoader> createState() => _TaskDetailLoaderState();
}

class _TaskDetailLoaderState extends ConsumerState<_TaskDetailLoader> {
  late Future<Task?> _future = ref.read(taskRepositoryProvider).fetchTask(widget.taskId);

  void _reload() => setState(() {
    _future = ref.read(taskRepositoryProvider).fetchTask(widget.taskId);
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snap.data;
        if (task == null) {
          return AlertDialog(
            content: Text(snap.hasError ? showErrorMessageOf(snap.error!) : 'この付箋は見つかりません'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
            ],
          );
        }
        return _TaskDetailDialog(task: task, onChanged: _reload);
      },
    );
  }
}

class _TaskDetailDialog extends ConsumerStatefulWidget {
  const _TaskDetailDialog({required this.task, required this.onChanged});

  final Task task;
  final VoidCallback onChanged;

  @override
  ConsumerState<_TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends ConsumerState<_TaskDetailDialog> {
  final _formKey = GlobalKey<TaskFormState>();
  late final _comment = TextEditingController(text: widget.task.latestComment ?? '');
  bool _busy = false;

  Task get task => widget.task;
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// 処理を実行して、ボード・マイタスク・この画面を最新にする
  Future<void> _run(Future<void> Function() action, {bool close = false}) async {
    setState(() => _busy = true);
    try {
      await action();
      await ref.read(boardTasksProvider(task.boardId).notifier).refetchTask(task.taskId);
      ref.read(myTasksProvider.notifier).refreshSoon();
      ref.invalidate(taskHistoryProvider(task.taskId));
      ref.invalidate(completedTasksProvider(task.teamId));
      if (!mounted) return;
      if (close) {
        Navigator.pop(context);
      } else {
        widget.onChanged();
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final draft = _formKey.currentState?.buildDraft();
    if (draft == null) return;
    await _run(() async {
      await _repo.updateTask(task.taskId, draft);
      await _repo.setAssignees(task, draft.assigneeIds);
    });
    if (mounted) showInfoSnack(context, '保存しました');
  }

  Future<void> _complete() async {
    // ダイアログを閉じた後も使える（ボード画面側の）context を先に取っておく
    final navigator = Navigator.of(context);
    final outerContext = navigator.context;
    navigator.pop();
    await completeTaskWithUndo(
      outerContext,
      taskId: task.taskId,
      title: task.title,
      boardId: task.boardId,
    );
  }

  Future<void> _return() async {
    final comment = await inputDialog(
      context,
      title: '差し戻す',
      label: '担当者へのメッセージ（必須・100文字以内）',
      maxLength: 100,
      multiline: true,
    );
    if (comment == null) return;
    await _run(() => _repo.review(task.taskId, approve: false, comment: comment));
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: '付箋を削除',
      message: '「${task.title}」をゴミ箱へ移動します。ゴミ箱から復元できます。',
      okLabel: '削除',
      danger: true,
    );
    if (!ok) return;
    await _run(() => _repo.delete(task.taskId), close: true);
  }

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(taskPermissionsProvider(task.teamId)).value;
    final members = ref.watch(teamMembersProvider(task.teamId)).value ?? const [];
    final memberMap = {for (final m in members) m.userId: m};
    final canEdit = (perms?.canEdit(task) ?? false) && !task.isDeleted;
    final canDelete = (perms?.canDelete(task) ?? false) && !task.isDeleted;
    final isDone = task.status == TaskStatus.done;
    final creator = memberMap[task.createdBy];

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
      title: Row(
        children: [
          Expanded(child: Text(task.title, overflow: TextOverflow.ellipsis)),
          if (task.isReturned) const _Tag(label: '差し戻し', color: Colors.deepOrange),
          if (task.isReviewed) const _Tag(label: '承認済み', color: Colors.green),
          if (task.isDeleted) const _Tag(label: 'ゴミ箱', color: Colors.grey),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- 作成者 ----
              Row(
                children: [
                  UserAvatar(profile: creator?.profile, size: 20, inactive: !(creator?.isActive ?? true)),
                  const SizedBox(width: 6),
                  Text('作成：${creator?.displayName ?? '不明'}',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (!canEdit && !task.isDeleted) ...[
                    const Spacer(),
                    Text(
                      '※ 編集できるのはリーダーと担当者です',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ---- ステータス ----
              _Section(
                title: 'ステータス',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!isDone) ...[
                      SegmentedButton<TaskStatus>(
                        segments: const [
                          ButtonSegment(value: TaskStatus.todo, label: Text('未着手')),
                          ButtonSegment(value: TaskStatus.inProgress, label: Text('進行中')),
                        ],
                        selected: {task.status},
                        onSelectionChanged: canEdit && !_busy
                            ? (s) => _run(() => _repo.setStatus(task.taskId, s.first))
                            : null,
                      ),
                      FilledButton.icon(
                        onPressed: canEdit && !_busy ? _complete : null,
                        icon: const Icon(Icons.check),
                        label: const Text('完了にする'),
                      ),
                    ] else ...[
                      Text(
                        '完了（${task.completedAt == null ? '' : formatDateTime(task.completedAt!)}'
                        ' ${memberMap[task.completedBy]?.displayName ?? ''}）',
                      ),
                      // 完了タスクのレビュー（機能28）：リーダーのみ
                      if (perms?.canReview ?? false) ...[
                        FilledButton.icon(
                          onPressed: _busy || task.isReviewed
                              ? null
                              : () => _run(() => _repo.review(task.taskId, approve: true)),
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          label: Text(task.isReviewed ? '承認済み' : '承認する'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _return,
                          icon: const Icon(Icons.undo),
                          label: const Text('差し戻す'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // ---- 一言メッセージ（機能13）----
              _Section(
                title: '一言メッセージ（最新の指示・連絡）',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _comment,
                            enabled: canEdit,
                            maxLength: 100,
                            decoration: InputDecoration(
                              hintText: 'メッセージを入力（上書き保存されます）',
                              filled: task.isReturned,
                              fillColor: Colors.orange.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: canEdit && !_busy
                              ? () => _run(() => _repo.updateComment(task.taskId, _comment.text))
                              : null,
                          child: const Text('更新'),
                        ),
                      ],
                    ),
                    if (task.latestCommentAt != null)
                      Text(
                        '${memberMap[task.latestCommentBy]?.displayName ?? ''}  '
                        '${formatDateTime(task.latestCommentAt!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              // ---- 内容の編集 ----
              _Section(
                title: '内容',
                child: TaskForm(
                  key: _formKey,
                  initial: task,
                  enabled: canEdit,
                  members: members.where((m) => m.isActive).toList(),
                ),
              ),

              // ---- 履歴 ----
              _Section(
                title: 'ステータス履歴',
                child: ref.watch(taskHistoryProvider(task.taskId)).when(
                  data: (list) => list.isEmpty
                      ? const Text('まだ変更はありません')
                      : Column(
                          children: [
                            for (final h in list)
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: UserAvatar(profile: memberMap[h.userId]?.profile, size: 22),
                                title: Text('${h.fromStatus.label} → ${h.toStatus.label}'
                                    '${h.comment == null ? '' : '「${h.comment}」'}'),
                                subtitle: Text(
                                  '${memberMap[h.userId]?.displayName ?? ''}  ${formatDateTime(h.createdAt)}',
                                ),
                              ),
                          ],
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(showErrorMessageOf(e)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (canDelete)
          TextButton.icon(
            onPressed: _busy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('削除'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        if (canEdit)
          FilledButton(onPressed: _busy ? null : _save, child: const Text('保存')),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const Divider(height: 12),
        child,
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  );
}
