import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';

/// P0-01 ログイン画面。
///
/// TODO(フェーズ2): メール／パスワード入力、ログイン状態保持チェックボックス、
///   パスワード再設定・新規登録への導線を実装する。今は仮の画面。
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('付箋タスク', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('ログイン画面（フェーズ2で実装）'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.board),
              child: const Text('（仮）ボード画面を見る'),
            ),
          ],
        ),
      ),
    );
  }
}
