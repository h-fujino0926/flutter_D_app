import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/router.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/prefs/local_prefs.dart';

part 'window_mode_controller.g.dart';

/// ウィンドウの表示モード（A1：1つのウィンドウを切り替える方式）
enum WindowMode {
  /// 管理モード（メインウィンドウ）
  main,

  /// 日常モード（画面右端の常駐ミニウィンドウ）
  mini,

  /// ミニウィンドウを折りたたんだ状態（細いタブだけ）
  miniCollapsed,
}

/// ミニウィンドウの幅
const double kMiniWidth = 280;

/// 折りたたみ時の幅
const double kMiniCollapsedWidth = 40;

/// 管理モード ⇔ ミニモードの切り替え（機能29）。
@Riverpod(keepAlive: true)
class WindowModeController extends _$WindowModeController {
  @override
  WindowMode build() => WindowMode.main;

  /// ミニモードへ：右端に寄せ、枠なし・常に最前面・半透明にする
  Future<void> enterMini() async {
    if (!PlatformInfo.isDesktop) return;
    if (state == WindowMode.main) {
      // 戻るときのためにメインウィンドウの位置とサイズを覚えておく
      await ref.read(localPrefsProvider).setMainWindowBounds(await windowManager.getBounds());
    }
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
    await windowManager.setMinimumSize(const Size(kMiniCollapsedWidth, 200));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setOpacity(0.95);
    await _placeAtRightEdge(kMiniWidth);
    await windowManager.show();
    state = WindowMode.mini;
    ref.read(routerProvider).go(AppRoutes.mini);
  }

  /// 折りたたみ（細いタブだけ残す）／展開
  Future<void> toggleCollapse() async {
    if (state == WindowMode.main) return;
    final collapse = state == WindowMode.mini;
    await _placeAtRightEdge(collapse ? kMiniCollapsedWidth : kMiniWidth);
    state = collapse ? WindowMode.miniCollapsed : WindowMode.mini;
  }

  /// 管理モードへ戻る（[location] を指定するとその画面を開く）
  Future<void> exitMini({String location = AppRoutes.board}) async {
    if (!PlatformInfo.isDesktop) return;
    if (state != WindowMode.main) {
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setSkipTaskbar(false);
      await windowManager.setOpacity(1);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setMinimumSize(const Size(960, 600));
      final saved = ref.read(localPrefsProvider).mainWindowBounds;
      if (saved != null) {
        await windowManager.setBounds(saved);
      } else {
        await windowManager.setSize(const Size(1280, 800));
        await windowManager.center();
      }
      state = WindowMode.main;
    }
    ref.read(routerProvider).go(location);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _placeAtRightEdge(double width) async {
    final display = await screenRetriever.getPrimaryDisplay();
    final origin = display.visiblePosition ?? Offset.zero;
    final size = display.visibleSize ?? display.size;
    await windowManager.setBounds(
      Rect.fromLTWH(origin.dx + size.width - width, origin.dy, width, size.height),
    );
  }
}
