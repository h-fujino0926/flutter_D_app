import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 端末ごとに保存する設定（shared_preferences）。
///
/// DB（user_settings）ではなく端末に置くもの：
///   ・ログイン状態を保持するか（端末ごとに違ってよいため）
///   ・ログイン前に開いた招待URLの token（ログイン後に参加画面へ戻るため）
///   ・メインウィンドウの位置とサイズ（ミニモードから戻るため）
class LocalPrefs {
  LocalPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _keepLoggedIn = 'keep_logged_in';
  static const _pendingInviteToken = 'pending_invite_token';
  static const _mainWindowBounds = 'main_window_bounds';

  /// ログイン状態を保持するか（初期値：保持する）
  bool get keepLoggedIn => _prefs.getBool(_keepLoggedIn) ?? true;
  Future<void> setKeepLoggedIn(bool value) => _prefs.setBool(_keepLoggedIn, value);

  String? get pendingInviteToken => _prefs.getString(_pendingInviteToken);
  Future<void> setPendingInviteToken(String? token) => token == null
      ? _prefs.remove(_pendingInviteToken)
      : _prefs.setString(_pendingInviteToken, token);

  Rect? get mainWindowBounds {
    final raw = _prefs.getString(_mainWindowBounds);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return Rect.fromLTWH(
        (m['x'] as num).toDouble(),
        (m['y'] as num).toDouble(),
        (m['w'] as num).toDouble(),
        (m['h'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setMainWindowBounds(Rect r) => _prefs.setString(
    _mainWindowBounds,
    jsonEncode({'x': r.left, 'y': r.top, 'w': r.width, 'h': r.height}),
  );
}

/// main.dart で読み込んだ SharedPreferences を差し込む（override 前提）。
final localPrefsProvider = Provider<LocalPrefs>(
  (ref) => throw UnimplementedError('main.dart で override すること'),
);
