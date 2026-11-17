import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../board/presentation/widgets/my_tasks_panel.dart';
import '../../notification/application/notifications_controller.dart';
import '../../notification/presentation/notifications_page.dart';
import '../../task/application/my_tasks_controller.dart';

/// スマホ版（Android / iOS）：タスクと通知の参照だけ（A5）
///
/// 仮決定（E1）：
///   ・操作は「通知の既読化」だけ（付箋の編集・完了は PC で行う）
///   ・プッシュ通知なし（アプリを開いたときに一覧を表示。開いている間は Realtime で届く）
class MobileHomePage extends ConsumerWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    final tasks = ref.watch(myTasksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('付箋タスク'),
          actions: [
            IconButton(
              tooltip: 'ログアウト',
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'マイタスク'),
              Tab(
                child: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Text('通知'),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            tasks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => RefreshIndicator(
                onRefresh: () => ref.read(myTasksProvider.notifier).refresh(),
                child: list.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 120),
                        Center(child: Text('担当のタスクはありません')),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => MyTaskTile(task: list[i], showTeam: true),
                      ),
              ),
            ),
            const NotificationsPage(openTaskOnTap: false),
          ],
        ),
      ),
    );
  }
}
