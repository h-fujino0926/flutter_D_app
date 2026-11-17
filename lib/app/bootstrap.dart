import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../core/platform/platform_info.dart';
import '../core/prefs/local_prefs.dart';
import 'env.dart';

/// ウィンドウのタイトル（windows/runner/main.cpp と同じにすること）
const kAppTitle = '付箋タスク';

/// 起動時の初期化処理。env.json が無い場合は null を返す（設定エラー画面を出す）。
Future<LocalPrefs?> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');

  if (PlatformInfo.isDesktop) {
    await _setUpDesktopWindow();
    await localNotifier.setup(appName: kAppTitle);
    unawaited(_registerUrlScheme());
  }

  if (!Env.isConfigured) return null;

  final prefs = LocalPrefs(await SharedPreferences.getInstance());

  // セッション（ログイン状態）は supabase_flutter が端末に自動保存する。
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );

  // 「ログイン状態を保持しない」設定なら、起動時に前回のセッションを破棄する（7.1 の 2）
  final auth = Supabase.instance.client.auth;
  if (!prefs.keepLoggedIn && auth.currentSession != null) {
    await auth.signOut(scope: SignOutScope.local);
  }
  return prefs;
}

/// Windows のメインウィンドウの初期設定。
Future<void> _setUpDesktopWindow() async {
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    title: kAppTitle,
    size: Size(1280, 800),
    minimumSize: Size(960, 600),
    center: true,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// 招待URL（fusenapp://）をこのアプリで開けるように、ユーザー単位のレジストリに登録する。
/// インストーラー版・zip 版どちらでも動くよう、起動するたびに自分の exe の場所で上書きする
/// （両方入れている場合は「最後に起動した方」で開く：F6）。
Future<void> _registerUrlScheme() async {
  try {
    final exe = Platform.resolvedExecutable;
    const key = r'HKCU\Software\Classes\fusenapp';
    await Process.run('reg', ['add', key, '/ve', '/d', 'URL:fusenapp', '/f']);
    await Process.run('reg', ['add', key, '/v', 'URL Protocol', '/d', '', '/f']);
    await Process.run('reg', [
      'add',
      '$key\\shell\\open\\command',
      '/ve',
      '/d',
      '"$exe" "%1"',
      '/f',
    ]);
  } catch (_) {
    // 登録できなくても「URL を貼り付けて参加」で参加できる（7.7 の 5）
  }
}
