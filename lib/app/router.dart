import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/prefs/local_prefs.dart';
import '../core/supabase/supabase_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/verify_signup_page.dart';
import '../features/board/presentation/board_page.dart';
import '../features/invite/presentation/join_page.dart';
import '../features/mini_window/presentation/mini_page.dart';
import '../features/mobile/presentation/mobile_home_page.dart';
import '../features/notification/presentation/notifications_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/task/presentation/trash_page.dart';
import '../features/team/presentation/home_resolver_page.dart';
import '../features/team/presentation/setup_page.dart';
import '../features/team/presentation/team_manage_page.dart';
import 'routes.dart';

export 'routes.dart';

/// ログイン状態が変わったらルーターの redirect をやり直すための仕組み
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

/// ログインしていなくても開ける画面
const _publicRoutes = {
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.verifySignup,
  AppRoutes.resetPassword,
};

/// ルーター（7.1 の 6：セッションが切れたらログイン画面へ戻す）
final routerProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseProvider);
  final prefs = ref.watch(localPrefsProvider);
  final refresh = _AuthRefresh(client.auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = client.auth.currentSession != null;
      final location = state.matchedLocation;

      if (!loggedIn) {
        // ログイン前に招待URLを開いた → token を覚えておき、ログイン後に参加画面へ戻す（7.7）
        if (location == AppRoutes.join) {
          final token = state.uri.queryParameters['token'];
          if (token != null) unawaited(prefs.setPendingInviteToken(token));
        }
        return _publicRoutes.contains(location) ? null : AppRoutes.login;
      }
      // ログイン済みでログイン画面などを開こうとした → ホームへ
      // （パスワード再設定は途中でログイン状態になるので除外）
      if (location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.verifySignup) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.signup, builder: (_, _) => const SignupPage()),
      GoRoute(
        path: AppRoutes.verifySignup,
        builder: (_, state) => VerifySignupPage(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: AppRoutes.resetPassword, builder: (_, _) => const ResetPasswordPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeResolverPage()),
      GoRoute(path: AppRoutes.setup, builder: (_, _) => const SetupPage()),
      GoRoute(
        path: AppRoutes.board,
        builder: (_, state) => BoardPage(
          openTaskId: int.tryParse(state.uri.queryParameters['task'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/open-task/:id',
        builder: (_, state) => OpenTaskPage(taskId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.join,
        builder: (_, state) => JoinPage(token: state.uri.queryParameters['token']),
      ),
      GoRoute(path: AppRoutes.team, builder: (_, _) => const TeamManagePage()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: AppRoutes.notifications, builder: (_, _) => const NotificationsPage()),
      GoRoute(path: AppRoutes.trash, builder: (_, _) => const TrashPage()),
      GoRoute(path: AppRoutes.mini, builder: (_, _) => const MiniPage()),
      GoRoute(path: AppRoutes.mobile, builder: (_, _) => const MobileHomePage()),
    ],
  );
});
