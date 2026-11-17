import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

/// 認証まわり（Supabase Auth）の処理をまとめたクラス。
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
    await touchLastLogin();
  }

  /// 新規登録。メール確認が必要な設定（本番）の場合は true を返す。
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      // DB トリガー handle_new_user がここから表示名を取る
      data: {'display_name': displayName.trim()},
    );
    if (res.session == null) return true;
    await touchLastLogin();
    return false;
  }

  /// 新規登録の確認コード（6桁）を検証する（Confirm email が ON のとき）。
  Future<void> verifySignupCode({required String email, required String code}) async {
    await _auth.verifyOTP(type: OtpType.signup, email: email.trim(), token: code);
    await touchLastLogin();
  }

  Future<void> resendSignupCode(String email) =>
      _auth.resend(type: OtpType.signup, email: email.trim());

  /// パスワード再設定 ①：確認コードをメールで送る。
  Future<void> sendPasswordResetCode(String email) =>
      _auth.resetPasswordForEmail(email.trim());

  /// パスワード再設定 ②：確認コードを検証する（成功すると一時的にログイン状態になる）。
  Future<void> verifyRecoveryCode({required String email, required String code}) =>
      _auth.verifyOTP(type: OtpType.recovery, email: email.trim(), token: code);

  /// パスワード再設定 ③：新しいパスワードを設定する。
  Future<void> updatePassword(String password) =>
      _auth.updateUser(UserAttributes(password: password));

  /// ログアウト（この端末のセッションだけ破棄する）。
  Future<void> signOut() => _auth.signOut(scope: SignOutScope.local);

  /// profiles.last_login_at を更新する（失敗してもログイン自体は続ける）。
  Future<void> touchLastLogin() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _client
          .from('profiles')
          .update({'last_login_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', uid);
    } catch (_) {
      // 記録できなくても致命的ではないので無視する
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(ref.watch(supabaseProvider));
