import 'package:flutter/material.dart';

import '../errors/error_messages.dart';

/// エラーを日本語にして SnackBar で表示する（アプリが落ちないよう、例外は必ずここで受ける）。
void showErrorSnack(BuildContext context, Object error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(toJapaneseMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
}

/// 例外を画面表示用の日本語メッセージにする（context が無い場面用）
String showErrorMessageOf(Object error) => toJapaneseMessage(error);

void showInfoSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 「元に戻す」付きの SnackBar（完了時に 5 秒間表示する）。
void showUndoSnack(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: '元に戻す', onPressed: onUndo),
      ),
    );
}

/// はい／いいえの確認ダイアログ。
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String okLabel = 'OK',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(okLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// 1行テキストを入力してもらうダイアログ。
Future<String?> inputDialog(
  BuildContext context, {
  required String title,
  String label = '',
  String initial = '',
  int maxLength = 30,
  bool multiline = false,
  bool required = true,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxLength,
          maxLines: multiline ? 3 : 1,
          decoration: InputDecoration(labelText: label),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (required && text.isEmpty) return;
            Navigator.pop(context, text);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
