import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/utils/date_utils.dart';
import '../application/notifications_controller.dart';

/// P1-06 通知一覧：新しい順、未読は強調、クリックで該当付箋へ（既読にする）
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key, this.openTaskOnTap = true});

  /// スマホ版（閲覧専用）では付箋を開かず既読にするだけ
  final bool openTaskOnTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final controller = ref.read(notificationsProvider.notifier);
    final list = NotificationList(
      async: async,
      onTap: (n) => openTaskOnTap ? controller.open(n) : controller.markRead(n.notificationId),
      onRefresh: controller.reload,
    );
    if (!openTaskOnTap) return list;
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await controller.markAllRead();
              } catch (e) {
                if (context.mounted) showErrorSnack(context, e);
              }
            },
            child: const Text('すべて既読にする'),
          ),
        ],
      ),
      body: list,
    );
  }
}

class NotificationList extends StatelessWidget {
  const NotificationList({
    super.key,
    required this.async,
    required this.onTap,
    required this.onRefresh,
  });

  final AsyncValue<List<AppNotification>> async;
  final void Function(AppNotification) onTap;
  final Future<void> Function() onRefresh;

  IconData _icon(NotificationType type) => switch (type) {
    NotificationType.taskCompleted => Icons.check_circle,
    NotificationType.taskReturned => Icons.undo,
    NotificationType.taskApproved => Icons.thumb_up,
    NotificationType.messageUpdated => Icons.chat_bubble,
    NotificationType.taskAssigned => Icons.person_add,
  };

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(showErrorMessageOf(e))),
      data: (items) => items.isEmpty
          ? const Center(child: Text('通知はありません'))
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return ListTile(
                    tileColor: n.isRead ? null : Colors.amber.withValues(alpha: 0.12),
                    leading: Icon(_icon(n.type), color: n.isRead ? Colors.black38 : Colors.orange),
                    title: Text(
                      n.message,
                      style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text(formatDateTime(n.createdAt)),
                    trailing: n.isRead
                        ? null
                        : const Icon(Icons.circle, size: 10, color: Colors.orange),
                    onTap: () => onTap(n),
                  );
                },
              ),
            ),
    );
  }
}
