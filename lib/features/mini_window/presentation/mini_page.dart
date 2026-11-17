import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/routes.dart';
import '../../../core/models/models.dart';
import '../../board/presentation/widgets/my_tasks_panel.dart';
import '../../task/application/my_tasks_controller.dart';
import '../../task/presentation/task_actions.dart';
import '../application/window_mode_controller.dart';

/// P2-01 常駐ミニウィンドウ（日常モード・機能29）
///   ・所属する全チームの自分の担当付箋（未完了）を期限が近い順に表示
///   ・右へフリック or チェックで完了 → 5秒間 Undo
///   ・クリックでメインウィンドウに戻り、該当付箋の詳細を開く
class MiniPage extends ConsumerWidget {
  const MiniPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(windowModeControllerProvider);
    final controller = ref.read(windowModeControllerProvider.notifier);
    final async = ref.watch(myTasksProvider);
    final tasks = async.value ?? const <MyTask>[];

    if (mode == WindowMode.miniCollapsed) {
      // 折りたたみ：細いタブだけ（クリックで展開）
      return Scaffold(
        backgroundColor: const Color(0xFFFFF59D),
        body: InkWell(
          onTap: controller.toggleCollapse,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.chevron_left),
              const SizedBox(height: 8),
              Badge(
                label: Text('${tasks.length}'),
                child: const Icon(Icons.sticky_note_2),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 枠なしウィンドウなので、ここをドラッグしてウィンドウを動かせるようにする
          DragToMoveArea(
            child: Container(
              color: const Color(0xFFFFF59D),
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: Row(
                children: [
                  const Icon(Icons.sticky_note_2, size: 18),
                  const SizedBox(width: 6),
                  Text('マイタスク ${tasks.length}件', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    tooltip: '更新',
                    iconSize: 18,
                    onPressed: () => ref.read(myTasksProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: 'メインを開く',
                    iconSize: 18,
                    onPressed: () => controller.exitMini(),
                    icon: const Icon(Icons.open_in_full),
                  ),
                  IconButton(
                    tooltip: '折りたたむ',
                    iconSize: 18,
                    onPressed: controller.toggleCollapse,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: async.isLoading && !async.hasValue
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? const Center(child: Text('担当のタスクはありません 🎉'))
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final t = tasks[i];
                      return Dismissible(
                        key: ValueKey('mini-${t.taskId}'),
                        // 右へフリックで完了
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          color: Colors.green.shade300,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        onDismissed: (_) => completeTaskWithUndo(
                          context,
                          taskId: t.taskId,
                          title: t.title,
                        ),
                        child: MyTaskTile(
                          task: t,
                          showTeam: true,
                          onTap: () => controller.exitMini(location: AppRoutes.openTask(t.taskId)),
                          trailing: IconButton(
                            tooltip: '完了にする',
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () => completeTaskWithUndo(
                              context,
                              taskId: t.taskId,
                              title: t.title,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
