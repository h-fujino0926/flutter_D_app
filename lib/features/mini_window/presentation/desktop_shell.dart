import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../invite/presentation/join_page.dart';
import '../../team/application/team_providers.dart';
import '../application/window_mode_controller.dart';

/// Windows デスクトップ専用の常駐処理をまとめたウィジェット（アプリ全体を包む）。
///
///   ・×ボタン：ミニウィンドウ ON ならミニモードへ、OFF ならタスクトレイへ隠す（F5）
///   ・タスクトレイ：「メインを開く」「ミニウィンドウ表示切替」「終了」
///   ・招待URL（fusenapp://join?token=...）を受け取って参加画面を開く
class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell>
    with WindowListener, TrayListener {
  StreamSubscription<Uri>? _linkSub;

  static const _menuOpen = 'open';
  static const _menuToggleMini = 'toggle_mini';
  static const _menuQuit = 'quit';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    unawaited(_setUp());
  }

  Future<void> _setUp() async {
    await windowManager.setPreventClose(true);
    await trayManager.setIcon('assets/tray_icon.ico');
    await trayManager.setToolTip('付箋タスク');
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: _menuOpen, label: 'メインを開く'),
          MenuItem(key: _menuToggleMini, label: 'ミニウィンドウ表示切替'),
          MenuItem.separator(),
          MenuItem(key: _menuQuit, label: '終了'),
        ],
      ),
    );
    // 招待URL（起動時のリンクと、起動中に開かれたリンクの両方）
    _linkSub = AppLinks().uriLinkStream.listen(_onLink);
  }

  void _onLink(Uri uri) {
    if (uri.scheme != 'fusenapp' || uri.host != 'join') return;
    final token = parseInviteToken(uri.toString());
    if (token == null) return;
    unawaited(
      ref.read(windowModeControllerProvider.notifier).exitMini(location: AppRoutes.joinWithToken(token)),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    unawaited(_linkSub?.cancel());
    super.dispose();
  }

  // ---------------- ウィンドウ ----------------

  @override
  void onWindowClose() async {
    final loggedIn = ref.read(currentUserIdProvider) != null;
    final miniEnabled = ref.read(userSettingsProvider).value?.miniWindowEnabled ?? true;
    final mode = ref.read(windowModeControllerProvider);
    if (loggedIn && miniEnabled && mode == WindowMode.main) {
      await ref.read(windowModeControllerProvider.notifier).enterMini();
    } else {
      // メインを閉じてもタスクトレイには残る
      await windowManager.hide();
    }
  }

  // ---------------- タスクトレイ ----------------

  @override
  void onTrayIconMouseDown() {
    unawaited(_openMain());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final controller = ref.read(windowModeControllerProvider.notifier);
    switch (menuItem.key) {
      case _menuOpen:
        await _openMain();
      case _menuToggleMini:
        if (ref.read(currentUserIdProvider) == null) {
          await _openMain();
        } else if (ref.read(windowModeControllerProvider) == WindowMode.main) {
          await controller.enterMini();
        } else {
          await controller.exitMini();
        }
      case _menuQuit:
        await trayManager.destroy();
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
    }
  }

  Future<void> _openMain() async {
    final mode = ref.read(windowModeControllerProvider);
    if (mode == WindowMode.main) {
      await windowManager.show();
      await windowManager.focus();
    } else {
      final current = ref.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();
      await ref
          .read(windowModeControllerProvider.notifier)
          .exitMini(location: current == AppRoutes.mini ? AppRoutes.board : current);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
