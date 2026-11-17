import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/ui/code_input.dart';
import '../../../core/ui/feedback.dart';
import '../../team/application/team_providers.dart';
import '../../team/data/team_repository.dart';

/// 招待URL（またはトークン）からトークンを取り出す
String? parseInviteToken(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  final fromQuery = uri?.queryParameters['token'];
  if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
  // トークンだけ貼り付けた場合（16進数の文字列）
  if (RegExp(r'^[0-9a-fA-F]{16,}$').hasMatch(text)) return text;
  return null;
}

/// P0-03 パスコード入力（招待で参加：機能23）
///   招待URLを開く or URL を貼り付ける → 6桁のパスコード → 参加
class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  late final _url = TextEditingController(
    text: widget.token == null ? '' : AppRoutes.joinWithToken(widget.token!),
  );
  late String? _token = widget.token;
  String? _passcode;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final token = _token;
    final passcode = _passcode;
    if (token == null || passcode == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(teamRepositoryProvider)
          .joinTeam(token: token, passcode: passcode);
      if (!mounted) return;
      if (!result.ok) {
        var message = rpcErrorMessages[result.code] ?? '参加できませんでした';
        if (result.code == 'WRONG_PASSCODE' && result.remainingAttempts != null) {
          message += '（あと${result.remainingAttempts}回間違えるとこの招待は無効になります）';
        }
        setState(() => _error = message);
        return;
      }
      // 参加したチームのボードへ自動で移動
      ref.invalidate(myTeamsProvider);
      await ref.read(currentSelectionProvider.notifier).selectTeam(result.teamId!);
      if (!mounted) return;
      showInfoSnack(context, 'チームに参加しました');
      context.go(AppRoutes.board);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('招待で参加')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('① 招待URLを貼り付けてください'),
                const SizedBox(height: 8),
                TextField(
                  controller: _url,
                  decoration: InputDecoration(
                    hintText: 'fusenapp://join?token=...',
                    suffixIcon: _token != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  onChanged: (v) => setState(() => _token = parseInviteToken(v)),
                ),
                const SizedBox(height: 24),
                const Text('② 6桁のパスコードを入力してください'),
                const SizedBox(height: 8),
                Center(child: CodeInput(onChanged: (c) => setState(() => _passcode = c))),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  // 6桁そろうと参加ボタンが有効になる
                  onPressed: _token != null && _passcode != null && !_loading ? _join : null,
                  child: const Text('参加する'),
                ),
                TextButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go(AppRoutes.home),
                  child: const Text('戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
