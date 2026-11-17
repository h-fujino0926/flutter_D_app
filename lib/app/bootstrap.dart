import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../core/platform/platform_info.dart';
import 'env.dart';

/// 起動時の初期化処理。成功したら true を返す。
///
/// env.json が渡されていない場合は Supabase を初期化せず false を返す
/// （main.dart 側で設定エラー画面を出す）。
Future<bool> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformInfo.isDesktop) {
    await _setUpDesktopWindow();
  }

  if (!Env.isConfigured) {
    return false;
  }

  // セッション（ログイン状態）は supabase_flutter が端末に自動保存する。
  // 「ログイン状態を保持しない」場合の破棄処理はフェーズ2で追加する。
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  return true;
}

/// Windows のメインウィンドウの初期設定。
///
/// ミニモード（常駐ミニウィンドウ）への切り替えはフェーズ11で実装する。
/// 仮決定：1つのウィンドウを「管理モード ⇔ ミニモード」で切り替える方式（案①）。
Future<void> _setUpDesktopWindow() async {
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    title: '付箋タスク',
    size: Size(1280, 800),
    minimumSize: Size(960, 600),
    center: true,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
