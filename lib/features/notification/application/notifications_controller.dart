import 'dart:async';

import 'package:local_notifier/local_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/router.dart';
import '../../../core/models/models.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../task/application/my_tasks_controller.dart';
import '../data/notification_repository.dart';

part 'notifications_controller.g.dart';

/// 自分宛ての通知一覧と、そのリアルタイム受信（7.4）。
///
/// ログイン中はずっと `user:{uid}` チャンネルを購読し、
///   ・notifications の INSERT（自分宛て）→ 一覧に追加＋Windows のトースト通知
///   ・task_members の変更（自分の担当）→ マイタスクを取り直す
/// を行う。起動時は SELECT で未読を取り直す（起動していない間の通知の取りこぼし対策）。
@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  RealtimeChannel? _channel;
  bool _needsResync = false;

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  @override
  Future<List<AppNotification>> build() async {
    final uid = ref.watch(currentUserIdProvider);
    final client = ref.watch(supabaseProvider);
    if (uid == null) return const [];

    final channel = client
        .channel('user:$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_user_id',
            value: uid,
          ),
          callback: _onInserted,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'task_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) => ref.read(myTasksProvider.notifier).refreshSoon(),
        )
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            if (_needsResync) {
              _needsResync = false;
              await reload();
            }
          } else {
            _needsResync = true;
          }
        });
    _channel = channel;
    ref.onDispose(() {
      final ch = _channel;
      _channel = null;
      if (ch != null) unawaited(client.removeChannel(ch));
    });

    return _repo.fetchRecent();
  }

  void _onInserted(PostgresChangePayload payload) {
    final n = AppNotification.fromJson(payload.newRecord);
    final current = state.value ?? const [];
    if (current.any((e) => e.notificationId == n.notificationId)) return;
    state = AsyncData([n, ...current]);
    ref.read(myTasksProvider.notifier).refreshSoon();
    _showDesktopToast(n);
  }

  /// Windows のトースト通知。クリックで該当の付箋を開く。
  void _showDesktopToast(AppNotification n) {
    if (!PlatformInfo.isDesktop) return;
    final toast = LocalNotification(title: '付箋タスク', body: n.message);
    toast.onClick = () async {
      await windowManager.show();
      await windowManager.focus();
      await open(n);
    };
    unawaited(toast.show());
  }

  Future<void> reload() async {
    try {
      state = AsyncData(await _repo.fetchRecent());
    } catch (_) {
      // 次の機会に取り直す
    }
  }

  /// 通知をクリックしたとき：既読にして該当の付箋を開く
  Future<void> open(AppNotification n) async {
    await markRead(n.notificationId);
    final taskId = n.taskId;
    if (taskId != null) {
      ref.read(routerProvider).go(AppRoutes.openTask(taskId));
    }
  }

  Future<void> markRead(int notificationId) async {
    final current = state.value ?? const [];
    state = AsyncData([
      for (final e in current)
        e.notificationId == notificationId ? e.copyWith(isRead: true) : e,
    ]);
    try {
      await _repo.markRead(notificationId);
    } catch (_) {
      // 既読にできなくても表示上は既読のままにする（次回起動時に取り直される）
    }
  }

  Future<void> markAllRead() async {
    final current = state.value ?? const [];
    state = AsyncData([for (final e in current) e.copyWith(isRead: true)]);
    await _repo.markAllRead();
  }
}

/// 未読の件数（ヘッダーのベルに表示）
@riverpod
int unreadCount(Ref ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => !n.isRead).length;
}
