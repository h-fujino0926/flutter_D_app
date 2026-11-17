import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 6桁コードの入力欄（P0-03 パスコード入力、確認コード入力で使う）。
///
/// ・1文字入力すると次の枠へ自動で移動
/// ・空の枠で Backspace を押すと前の枠へ戻る
/// ・貼り付けると6枠に分けて入る
/// ・6桁そろうと [onCompleted] が呼ばれる（そろわなくなると null）
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.digitsOnly = false,
  });

  /// 6桁そろったらコード、そろっていなければ null
  final ValueChanged<String?> onChanged;
  final int length;

  /// 数字だけ（確認コード）／英数字（招待パスコード）
  final bool digitsOnly;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (i) {
      return FocusNode(
        onKeyEvent: (node, event) {
          // 空の枠で Backspace → 前の枠へ
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[i].text.isEmpty &&
              i > 0) {
            _controllers[i - 1].clear();
            _focusNodes[i - 1].requestFocus();
            _notify();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      );
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _normalize(String value) {
    final upper = value.toUpperCase();
    final pattern = widget.digitsOnly ? RegExp(r'[0-9]') : RegExp(r'[A-Z0-9]');
    return upper.split('').where(pattern.hasMatch).join();
  }

  void _onChanged(int index, String value) {
    final chars = _normalize(value);
    if (chars.length > 1) {
      // 貼り付け：この枠から順に分配する
      for (var i = 0; i < chars.length && index + i < widget.length; i++) {
        _controllers[index + i].text = chars[i];
      }
      final next = (index + chars.length).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
    } else {
      _controllers[index].text = chars;
      _controllers[index].selection = TextSelection.collapsed(offset: chars.length);
      if (chars.isNotEmpty && index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }
    _notify();
  }

  void _notify() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code.length == widget.length ? code : null);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 48,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                autofocus: i == 0,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                keyboardType:
                    widget.digitsOnly ? TextInputType.number : TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          ),
      ],
    );
  }
}
