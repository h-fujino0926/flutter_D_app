import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/prefs/local_prefs.dart';
import '../../../core/ui/feedback.dart';
import '../data/auth_repository.dart';
import 'auth_scaffold.dart';

/// P0-01 ログイン画面
///
/// 「この端末でログイン状態を保持する」はここのチェックボックスで決める（B17：P0-05 は廃止）。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _keepLoggedIn = ref.read(localPrefsProvider).keepLoggedIn;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(localPrefsProvider).setKeepLoggedIn(_keepLoggedIn);
      await ref
          .read(authRepositoryProvider)
          .signIn(email: _email.text, password: _password.text);
      // ログインできたら、ルーターの redirect がホーム（前回のボード）へ移動させる
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'ログイン',
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
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'パスワードを入力してください' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _keepLoggedIn,
          onChanged: (v) => setState(() => _keepLoggedIn = v ?? true),
          title: const Text('この端末でログイン状態を保持する'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('ログイン'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push(AppRoutes.resetPassword),
          child: const Text('パスワードをお忘れですか？'),
        ),
        // 仮決定（E1）：スマホ版は閲覧専用なので新規登録は PC から行う
        if (!PlatformInfo.isMobile)
          TextButton(
            onPressed: () => context.push(AppRoutes.signup),
            child: const Text('新規登録はこちら'),
          ),
      ],
    );
  }
}
