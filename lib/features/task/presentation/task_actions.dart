import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../board/application/board_controller.dart';
import '../application/my_tasks_controller.dart';
import '../data/task_repository.dart';

/// 付箋を完了にして、5秒間「元に戻す」を表示する（機能8）。
///
/// 完了すると付箋のウィジェットや詳細ダイアログは画面から消えるため、
/// 呼び出し元の `ref` ではなくアプリ全体の ProviderContainer と ScaffoldMessenger を
/// 最初に取得して使う（「元に戻す」は消えた後に押されるため）。
///
/// [boardId] があるときはボードの状態も更新する（ボード画面・詳細画面）。
/// ミニウィンドウからはボードを開いていないので null で呼ぶ。
Future<void> completeTaskWithUndo(
  BuildContext context, {
  required int taskId,
  required String title,
  int? boardId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.error;

  void showError(Object e) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(toJapaneseMessage(e)), backgroundColor: errorColor));

  final myTasks = container.read(myTasksProvider.notifier);
  try {
    if (boardId != null) {
      await container.read(boardTasksProvider(boardId).notifier).completeTask(taskId);
    } else {
      myTasks.removeLocal(taskId);
      await container.read(taskRepositoryProvider).complete(taskId);
    }
  } catch (e) {
    myTasks.refreshSoon();
    showError(e);
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('「$title」を完了しました'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () async {
            try {
              if (boardId != null) {
                await container.read(boardTasksProvider(boardId).notifier).undoComplete(taskId);
              } else {
                await container.read(taskRepositoryProvider).undoComplete(taskId);
                await myTasks.refresh();
              }
            } catch (e) {
              // 10秒を過ぎた（UNDO_EXPIRED）なども日本語で表示
              showError(e);
            }
          },
        ),
      ),
    );
}
