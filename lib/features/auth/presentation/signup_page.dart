import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/ui/feedback.dart';
import '../data/auth_repository.dart';
import 'auth_scaffold.dart';

/// P0-02 新規登録画面
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _displayName = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final needsVerification = await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _email.text,
            password: _password.text,
            displayName: _displayName.text,
          );
      if (!mounted) return;
      if (needsVerification) {
        // 本番（Confirm email が ON）：メールの確認コードを入力する画面へ（B16）
        context.go(
          Uri(
            path: AppRoutes.verifySignup,
            queryParameters: {'email': _email.text.trim()},
          ).toString(),
        );
      }
      // メール確認なし（開発中）の場合はそのままログイン状態になり、redirect でホームへ
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '新規登録',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'パスワード',
                  helperText: '8文字以上',
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordConfirm,
                decoration: const InputDecoration(labelText: 'パスワード（確認）'),
                obscureText: true,
                validator: (v) =>
                    v != _password.text ? 'パスワードが一致しません' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: '表示名'),
                maxLength: 20,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return '表示名を入力してください';
                  if (t.length > 20) return '表示名は20文字以内で入力してください';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: const Text('登録する'),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('ログイン画面へ戻る'),
        ),
      ],
    );
  }
}
