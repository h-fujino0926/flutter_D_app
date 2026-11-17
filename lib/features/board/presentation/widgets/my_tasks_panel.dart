import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../core/ui/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../task/application/my_tasks_controller.dart';
import '../../../task/presentation/task_detail_dialog.dart';

/// 右パネル：現在のチームの自分の担当タスク（期限が近い順）
class MyTasksPanel extends ConsumerWidget {
  const MyTasksPanel({super.key, required this.teamId});

  final int teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myTasksProvider);
    final tasks = (async.value ?? const <MyTask>[]).where((t) => t.teamId == teamId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
          child: Row(
            children: [
              Text('マイタスク', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 6),
              Text('${tasks.length}件', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              IconButton(
                tooltip: '更新',
                iconSize: 18,
                onPressed: () => ref.read(myTasksProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: async.isLoading && !async.hasValue
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(child: Text('担当のタスクはありません'))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => MyTaskTile(
                    task: tasks[i],
                    onTap: () => showTaskDetailDialog(context, taskId: tasks[i].taskId),
                  ),
                ),
        ),
      ],
    );
  }
}

/// マイタスク1件の表示（右パネル・ミニウィンドウ・スマホで共通）
class MyTaskTile extends StatelessWidget {
  const MyTaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.showTeam = false,
    this.trailing,
  });

  final MyTask task;
  final VoidCallback? onTap;
  final bool showTeam;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final due = dueStateOf(task.dueAt);
    final dueColor = switch (due) {
      DueState.overdue => Colors.red.shade700,
      DueState.soon => Colors.orange.shade800,
      _ => Colors.black54,
    };
    return Material(
      color: colorFromHex(task.color),
      elevation: 1,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTeam)
                      Text(
                        '${task.teamName} / ${task.boardName}',
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Row(
                      children: [
                        if (task.dueAt != null)
                          Text(
                            '〆 ${formatDue(task.dueAt, hasTime: task.dueHasTime)}'
                            '${due == DueState.overdue ? '（期限切れ）' : ''}',
                            style: TextStyle(fontSize: 11, color: dueColor),
                          )
                        else
                          const Text('締切なし', style: TextStyle(fontSize: 11, color: Colors.black45)),
                        const SizedBox(width: 6),
                        if (task.returnedAt != null)
                          const Text(
                            '差し戻し',
                            style: TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        if (task.status == TaskStatus.inProgress && task.returnedAt == null)
                          const Text('進行中', style: TextStyle(fontSize: 11, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
