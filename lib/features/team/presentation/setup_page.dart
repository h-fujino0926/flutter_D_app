import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../auth/data/auth_repository.dart';
import 'team_dialogs.dart';

/// チームに1つも所属していないときの画面（7.1 の 4）
class SetupPage extends ConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ようこそ！',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'まだチームに参加していません。\nチームを作成するか、招待で参加してください。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      final id = await showCreateTeamDialog(context, ref);
                      if (id != null && context.mounted) context.go(AppRoutes.board);
                    },
                    icon: const Icon(Icons.group_add),
                    label: const Text('チームを作成'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.join),
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('招待で参加'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text('ログアウト'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
