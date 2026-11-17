import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform/platform_info.dart';
import '../features/mini_window/presentation/desktop_shell.dart';
import '../features/notification/application/notifications_controller.dart';
import 'router.dart';
import 'theme.dart';

/// アプリのルートウィジェット。
class FusenApp extends ConsumerWidget {
  const FusenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ログイン中はずっと自分宛ての通知を購読しておく（7.4 の 4）
    ref.watch(notificationsProvider);

    return MaterialApp.router(
      title: '付箋タスク',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return PlatformInfo.isDesktop ? DesktopShell(child: content) : content;
      },
    );
  }
}

/// env.json が渡されずに起動されたときに出す画面。
/// （チームメンバーが起動方法を間違えたときに原因がすぐ分かるように）
class MissingEnvApp extends StatelessWidget {
  const MissingEnvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: SelectableText(
              '接続設定が読み込まれていません。\n\n'
              '1. env.example.json をコピーして env.json を作成\n'
              '2. 次のコマンドで起動してください\n'
              '   flutter run -d windows --dart-define-from-file=env.json',
            ),
          ),
        ),
      ),
    );
  }
}
