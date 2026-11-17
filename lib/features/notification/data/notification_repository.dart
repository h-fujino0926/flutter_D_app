import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';

part 'notification_repository.g.dart';

/// 通知（notifications）の DB 操作。作成は DB のトリガー／RPC だけが行う。
class NotificationRepository {
  NotificationRepository(this._client);

  final SupabaseClient _client;

  /// 自分宛ての通知（新しい順・最大100件）。RLS で自分宛てだけが返る。
  Future<List<AppNotification>> fetchRecent() async {
    final rows = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(AppNotification.fromJson).toList();
  }

  Future<void> markRead(int notificationId) => _client
      .from('notifications')
      .update({'is_read': true})
      .eq('notification_id', notificationId);

  Future<void> markAllRead() =>
      _client.from('notifications').update({'is_read': true}).eq('is_read', false);
}

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository(ref.watch(supabaseProvider));
