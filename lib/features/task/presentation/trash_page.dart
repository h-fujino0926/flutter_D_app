import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/ui/colors.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/ui/user_avatar.dart';
import '../../../core/utils/date_utils.dart';
import '../../board/application/board_controller.dart';
import '../../team/application/team_providers.dart';
import '../application/my_tasks_controller.dart';
import '../application/task_providers.dart';
import '../data/task_repository.dart';
import 'task_detail_dialog.dart';

/// P1-07 ゴミ箱・完了ログ（機能12）。現在のチームが対象。
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(currentSelectionProvider);
    if (selection == null) return const Scaffold();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('完了ログ・ゴミ箱'),
          bottom: const TabBar(tabs: [Tab(text: '完了ログ'), Tab(text: 'ゴミ箱')]),
        ),
        body: TabBarView(
          children: [
            _TaskList(teamId: selection.teamId, boardId: selection.boardId, trash: false),
            _TaskList(teamId: selection.teamId, boardId: selection.boardId, trash: true),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.teamId, required this.boardId, required this.trash});

  final int teamId;
  final int boardId;
  final bool trash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = trash ? trashTasksProvider(teamId) : completedTasksProvider(teamId);
    final async = ref.watch(provider);
    final perms = ref.watch(taskPermissionsProvider(teamId)).value;
    final members = ref.watch(memberMapProvider(teamId)).value ?? const {};
    final boards = ref.watch(teamBoardsProvider(teamId)).value ?? const <Board>[];
    final boardNames = {for (final b in boards) b.boardId: b.name};
    final repo = ref.read(taskRepositoryProvider);

    Future<void> run(Future<void> Function() action, String done) async {
      try {
        await action();
        ref.invalidate(trashTasksProvider(teamId));
        ref.invalidate(completedTasksProvider(teamId));
        await ref.read(boardTasksProvider(boardId).notifier).refreshAll();
        ref.read(myTasksProvider.notifier).refreshSoon();
        if (context.mounted) showInfoSnack(context, done);
      } catch (e) {
        if (context.mounted) showErrorSnack(context, e);
      }
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(showErrorMessageOf(e))),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(child: Text(trash ? 'ゴミ箱は空です' : '完了した付箋はまだありません'));
        }
        return RefreshIndicator(
          onRefresh: () => trash
              ? ref.refresh(trashTasksProvider(teamId).future)
              : ref.refresh(completedTasksProvider(teamId).future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = tasks[i];
              final whoId = trash ? null : t.completedBy;
              final when = trash ? t.deletedAt : t.completedAt;
              return ListTile(
                leading: Container(width: 16, height: 40, color: colorFromHex(t.color)),
                title: Row(
                  children: [
                    Flexible(child: Text(t.title, overflow: TextOverflow.ellipsis)),
                    if (!trash && t.isReviewed)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Chip(label: Text('承認済み'), visualDensity: VisualDensity.compact),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    if (whoId != null) ...[
                      UserAvatar(profile: members[whoId]?.profile, size: 16),
                      const SizedBox(width: 4),
                      Text(members[whoId]?.displayName ?? ''),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${boardNames[t.boardId] ?? ''} ・ ${trash ? '削除' : '完了'} '
                      '${when == null ? '' : formatDateTime(when)}',
                    ),
                  ],
                ),
                onTap: () => showTaskDetailDialog(context, taskId: t.taskId),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    if (trash && (perms?.canDelete(t) ?? false))
                      OutlinedButton.icon(
                        onPressed: () => run(() => repo.restore(t.taskId), 'ボードに復元しました'),
                        icon: const Icon(Icons.restore),
                        label: const Text('復元'),
                      ),
                    if (!trash && (perms?.canReview ?? false) && !t.isReviewed)
                      FilledButton.tonal(
                        onPressed: () => run(
                          () => repo.review(t.taskId, approve: true),
                          '承認しました',
                        ),
                        child: const Text('承認'),
                      ),
                    if (!trash && (perms?.canReview ?? false))
                      OutlinedButton(
                        onPressed: () async {
                          final comment = await inputDialog(
                            context,
                            title: '差し戻す',
                            label: '担当者へのメッセージ（必須・100文字以内）',
                            maxLength: 100,
                            multiline: true,
                          );
                          if (comment == null) return;
                          await run(
                            () => repo.review(t.taskId, approve: false, comment: comment),
                            '差し戻しました',
                          );
                        },
                        child: const Text('差し戻し'),
                      ),
                    if (!trash && (perms?.canEdit(t) ?? false))
                      OutlinedButton.icon(
                        onPressed: () => run(
                          () => repo.restoreCompleted(t.taskId),
                          '未着手に戻してボードに復元しました',
                        ),
                        icon: const Icon(Icons.restore),
                        label: const Text('ボードに戻す'),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
