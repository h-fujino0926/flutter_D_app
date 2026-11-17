import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/prefs/local_prefs.dart';
import '../../../core/ui/colors.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/ui/user_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../team/application/team_providers.dart';
import '../data/settings_repository.dart';

/// P1-09 設定メニュー
///   プロフィール編集（機能17）、ログイン保持設定、ミニウィンドウ ON/OFF、
///   Googleカレンダー連携（追加候補・未実装）、ログアウト
///
/// ※ 設定画面に追加する項目はまだ受け取っていないため、プロンプトに書かれた項目だけ実装している。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final settings = ref.watch(userSettingsProvider).value;
    final prefs = ref.watch(localPrefsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: profile.when(
                data: (p) => _ProfileEditor(profile: p),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(showErrorMessageOf(e)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _KeepLoginTile(prefs: prefs),
                if (PlatformInfo.isDesktop)
                  SwitchListTile(
                    title: const Text('常駐ミニウィンドウを使う'),
                    subtitle: const Text('ON：×ボタンでミニウィンドウになります ／ OFF：×ボタンでタスクトレイに隠れます'),
                    value: settings?.miniWindowEnabled ?? true,
                    onChanged: settings == null
                        ? null
                        : (v) async {
                            try {
                              await ref.read(settingsRepositoryProvider).setMiniWindowEnabled(v);
                              ref.invalidate(userSettingsProvider);
                            } catch (e) {
                              if (context.mounted) showErrorSnack(context, e);
                            }
                          },
                  ),
                const ListTile(
                  enabled: false,
                  leading: Icon(Icons.event),
                  title: Text('Googleカレンダー連携'),
                  subtitle: Text('準備中（フェーズ13：着手前に相談）'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () async {
              final ok = await confirmDialog(context, title: 'ログアウト', message: 'ログアウトしますか？');
              if (ok) await ref.read(authRepositoryProvider).signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }
}

class _KeepLoginTile extends StatefulWidget {
  const _KeepLoginTile({required this.prefs});
  final LocalPrefs prefs;

  @override
  State<_KeepLoginTile> createState() => _KeepLoginTileState();
}

class _KeepLoginTileState extends State<_KeepLoginTile> {
  late bool _value = widget.prefs.keepLoggedIn;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: const Text('この端末でログイン状態を保持する'),
    subtitle: const Text('OFF にすると、次回起動時にログイン画面が表示されます'),
    value: _value,
    onChanged: (v) async {
      setState(() => _value = v);
      await widget.prefs.setKeepLoggedIn(v);
    },
  );
}

/// プロフィール編集（表示名・アイコン色）
class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.profile});
  final Profile profile;

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  late final _name = TextEditingController(text: widget.profile.displayName);
  late String _color = widget.profile.iconColor;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 20) {
      showInfoSnack(context, '表示名は1〜20文字で入力してください');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).updateProfile(displayName: name, iconColor: _color);
      ref.invalidate(myProfileProvider);
      // チームのメンバー表示も更新する
      final sel = ref.read(currentSelectionProvider);
      if (sel != null) ref.invalidate(teamMembersProvider(sel.teamId));
      if (mounted) showInfoSnack(context, 'プロフィールを保存しました');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.profile.copyWith(
      displayName: _name.text.isEmpty ? '?' : _name.text,
      iconColor: _color,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('プロフィール', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            UserAvatar(profile: preview, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _name,
                maxLength: 20,
                decoration: const InputDecoration(labelText: '表示名'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Text('メール：${widget.profile.email}'),
        const SizedBox(height: 12),
        const Text('アイコンの色'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final c in iconColorPresets)
              InkWell(
                onTap: () => setState(() => _color = c),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorFromHex(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color == c ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: _saving ? null : _save, child: const Text('保存')),
        ),
      ],
    );
  }
}
