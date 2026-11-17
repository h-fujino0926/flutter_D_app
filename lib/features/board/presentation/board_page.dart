import 'package:flutter/material.dart';

/// P1-01 メイン（ボード）画面。
///
/// レイアウトはいただいた画面イメージに合わせた骨組みだけ（中身はフェーズ3〜で実装）。
///   ヘッダー：設定 ／ 日付（カレンダー） ／ チーム・通知・アカウント
///   左：チームのタスクを自由配置するキャンバス（列なし）
///   右上：［追加］［完］（完 = 完了ログ P1-07）
///   右：現在のチームのマイタスク（期限順）
class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: _Panel(child: Text('ここにチームのタスクがまとめて表示')),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.add),
                                label: const Text('追加'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const OutlinedButton(
                              onPressed: null,
                              child: Text('完'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Expanded(
                          child: _Panel(
                            child: Text(
                              '現在のチームの\nマイタスク\n（期限順）',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.settings),
            label: const Text('設定'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.calendar_month),
            label: const Text('カレンダー'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.groups),
            label: const Text('チーム'),
          ),
          const IconButton(onPressed: null, icon: Icon(Icons.notifications)),
          const IconButton(onPressed: null, icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}

/// 角丸の枠。
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: padding == null ? Alignment.center : null,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: child,
    );
  }
}
