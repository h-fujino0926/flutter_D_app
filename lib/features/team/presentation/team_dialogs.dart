import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/feedback.dart';
import '../../../core/utils/date_utils.dart';
import '../application/team_providers.dart';
import '../data/team_repository.dart';

/// チーム作成ダイアログ（機能19）。作成したチームの team_id を返す。
Future<int?> showCreateTeamDialog(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final description = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('チームを作成'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'チーム名（必須）'),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'チーム名を入力してください' : null,
              ),
              TextFormField(
                controller: description,
                maxLength: 200,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '説明（任意）'),
              ),
              const Text('作成したあなたがリーダーになり、ボード「メイン」が自動で作られます。'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(context, true);
          },
          child: const Text('作成'),
        ),
      ],
    ),
  );
  if (ok != true) return null;
  try {
    final teamId = await ref
        .read(teamRepositoryProvider)
        .createTeam(name: name.text.trim(), description: description.text.trim());
    ref.invalidate(myTeamsProvider);
    await ref.read(currentSelectionProvider.notifier).selectTeam(teamId);
    return teamId;
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
    return null;
  }
}

/// 招待の発行結果ダイアログ（機能21・22）
/// パスコードはこの画面を閉じると二度と表示できない。
Future<void> showInviteResultDialog(BuildContext context, InviteInfo invite) {
  Widget copyRow(String label, String value) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: SelectableText(
      value,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
    ),
    trailing: IconButton(
      tooltip: 'コピー',
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        showInfoSnack(context, '$labelをコピーしました');
      },
    ),
  );

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('招待を発行しました'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            copyRow('招待URL', invite.url),
            copyRow('パスコード（6桁）', invite.passcode),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('有効期限'),
              subtitle: Text('${formatDateTime(invite.expiresAt)} まで（発行から72時間）'),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withValues(alpha: 0.15),
              child: const Text(
                '⚠ パスコードはこの画面を閉じると二度と表示できません。\n'
                '招待URLとパスコードの両方を、参加してほしい人に伝えてください。',
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
      ],
    ),
  );
}
