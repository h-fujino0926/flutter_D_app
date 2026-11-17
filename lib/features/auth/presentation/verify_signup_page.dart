import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/ui/code_input.dart';
import '../../../core/ui/feedback.dart';
import '../data/auth_repository.dart';
import 'auth_scaffold.dart';

/// 新規登録の確認コード入力（※設計書に無い画面。本番で Confirm email を ON にしたとき用：B16）
class VerifySignupPage extends ConsumerStatefulWidget {
  const VerifySignupPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifySignupPage> createState() => _VerifySignupPageState();
}

class _VerifySignupPageState extends ConsumerState<VerifySignupPage> {
  String? _code;
  bool _loading = false;

  Future<void> _verify() async {
    final code = _code;
    if (code == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifySignupCode(email: widget.email, code: code);
      // ログイン状態になるので redirect でホームへ
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendSignupCode(widget.email);
      if (mounted) showInfoSnack(context, '確認コードを再送しました');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'メールアドレスの確認',
      children: [
        Text(
          '${widget.email} に確認コード（6桁）を送信しました。\nメールに書かれたコードを入力してください。',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: CodeInput(
            digitsOnly: true,
            onChanged: (code) => setState(() => _code = code),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _code == null || _loading ? null : _verify,
          child: const Text('確認する'),
        ),
        TextButton(onPressed: _resend, child: const Text('コードを再送する')),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('ログイン画面へ戻る'),
        ),
      ],
    );
  }
}
