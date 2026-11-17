import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/board/presentation/board_page.dart';

/// 画面のパス。画面IDは設計書（27_画面設計書）に合わせてコメントに書く。
class AppRoutes {
  const AppRoutes._();

  /// P0-01 ログイン
  static const login = '/login';

  /// P1-01 メイン（ボード）
  static const board = '/board';
}

/// ルーター。
///
/// TODO(フェーズ2): ログイン状態（onAuthStateChange）を監視して、
///   未ログインならログイン画面へ戻す redirect を追加する。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.board,
        builder: (context, state) => const BoardPage(),
      ),
    ],
  );
});
