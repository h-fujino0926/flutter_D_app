import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/ui/code_input.dart';
import '../../../core/ui/feedback.dart';
import '../data/auth_repository.dart';
import 'auth_scaffold.dart';

/// P0-04 パスワード再設定（デスクトップ向けのコード方式）
///   ① メール入力 → ② 6桁の確認コード入力 → ③ 新しいパスワード → ログイン画面へ
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

enum _Step { email, code, password }

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  _Step _step = _Step.email;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  String? _code;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
    if (validateEmail(_email.text) != null) {
      showInfoSnack(context, 'メールアドレスを正しく入力してください');
      return;
    }
    await ref.read(authRepositoryProvider).sendPasswordResetCode(_email.text);
    setState(() => _step = _Step.code);
  });

  Future<void> _verifyCode() => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .verifyRecoveryCode(email: _email.text, code: _code!);
    setState(() => _step = _Step.password);
  });

  Future<void> _updatePassword() => _run(() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final repo = ref.read(authRepositoryProvider);
    await repo.updatePassword(_password.text);
    // 新しいパスワードで改めてログインしてもらう
    await repo.signOut();
    if (!mounted) return;
    showInfoSnack(context, 'パスワードを変更しました。新しいパスワードでログインしてください');
    context.go(AppRoutes.login);
  });

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'パスワード再設定',
      children: [
        ...switch (_step) {
          _Step.email => [
            const Text('登録したメールアドレスを入力してください。確認コードを送信します。'),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _sendCode(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _sendCode,
              child: const Text('確認コードを送信'),
            ),
          ],
          _Step.code => [
            Text(
              '確認コードを送信しました。\n${_email.text.trim()} に届いた6桁のコードを入力してください。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: CodeInput(
                digitsOnly: true,
                onChanged: (c) => setState(() => _code = c),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _code == null || _loading ? null : _verifyCode,
              child: const Text('次へ'),
            ),
            TextButton(
              onPressed: _loading ? null : _sendCode,
              child: const Text('コードを再送する'),
            ),
          ],
          _Step.password => [
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: '新しいパスワード',
                      helperText: '8文字以上',
                    ),
                    obscureText: true,
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordConfirm,
                    decoration: const InputDecoration(labelText: '新しいパスワード（確認）'),
                    obscureText: true,
                    validator: (v) =>
                        v != _password.text ? 'パスワードが一致しません' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _updatePassword,
              child: const Text('パスワードを変更'),
            ),
          ],
        },
        TextButton(
          onPressed: () async {
            // 途中（コード確認後）で戻る場合は一時的なログイン状態を破棄する
            if (_step == _Step.password) {
              await ref.read(authRepositoryProvider).signOut();
            }
            if (context.mounted) context.go(AppRoutes.login);
          },
          child: const Text('ログイン画面へ戻る'),
        ),
      ],
    );
  }
}
