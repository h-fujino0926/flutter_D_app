import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';

part 'settings_repository.g.dart';

/// プロフィールとユーザー設定（user_settings）の DB 操作。
class SettingsRepository {
  SettingsRepository(this._client);

  final SupabaseClient _client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Not signed in');
    return uid;
  }

  Future<Profile> fetchMyProfile() async {
    final row = await _client
        .from('profiles')
        .select('id, display_name, email, icon_color')
        .eq('id', _uid)
        .single();
    return Profile.fromJson(row);
  }

  Future<void> updateProfile({required String displayName, required String iconColor}) =>
      _client
          .from('profiles')
          .update({'display_name': displayName, 'icon_color': iconColor})
          .eq('id', _uid);

  Future<UserSettings> fetchSettings() async {
    final row = await _client
        .from('user_settings')
        .select('user_id, last_team_id, last_board_id, mini_window_enabled, google_calendar_linked')
        .eq('user_id', _uid)
        .maybeSingle();
    return row == null ? UserSettings(userId: _uid) : UserSettings.fromJson(row);
  }

  // ※ user_settings の行は新規登録時にトリガーで作られるので、upsert ではなく update を使う
  //   （upsert だと user_id 列の UPDATE 権限が必要になり、列単位 GRANT で拒否されるため）

  /// 前回開いていたチーム・ボードを保存（機能18）
  Future<void> saveLastSelection({required int teamId, required int boardId}) => _client
      .from('user_settings')
      .update({'last_team_id': teamId, 'last_board_id': boardId})
      .eq('user_id', _uid);

  /// 付箋がどのチーム・ボードにあるか（通知などから付箋を開くとき用）
  Future<({int teamId, int boardId})?> findTaskLocation(int taskId) async {
    final row = await _client
        .from('tasks')
        .select('team_id, board_id')
        .eq('task_id', taskId)
        .maybeSingle();
    if (row == null) return null;
    return (
      teamId: (row['team_id'] as num).toInt(),
      boardId: (row['board_id'] as num).toInt(),
    );
  }

  Future<void> setMiniWindowEnabled(bool enabled) => _client
      .from('user_settings')
      .update({'mini_window_enabled': enabled})
      .eq('user_id', _uid);
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(supabaseProvider));
