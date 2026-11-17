import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/ui/user_avatar.dart';
import '../application/team_providers.dart';
import '../data/team_repository.dart';
import 'team_dialogs.dart';

/// P1-08 チーム管理
///   チーム作成・一覧／切替（19,20）、ボード作成（26）、メンバー一覧・ロール変更・退出（24,25）、
///   招待発行（21,22）、チーム情報の編集・削除（owner のみ）
class TeamManagePage extends ConsumerWidget {
  const TeamManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(currentSelectionProvider);
    if (selection == null) return const Scaffold();
    final teamId = selection.teamId;
    final uid = ref.watch(currentUserIdProvider);
    final teams = ref.watch(myTeamsProvider).value ?? const <Team>[];
    final team = teams.where((t) => t.teamId == teamId).firstOrNull;
    final me = ref.watch(myMembershipProvider(teamId)).value;
    final isLeader = me?.isLeader ?? false;
    final isOwner = team?.ownerUserId == uid;
    final repo = ref.read(teamRepositoryProvider);

    Future<void> run(Future<void> Function() action, {String? done}) async {
      try {
        await action();
        ref.invalidate(myTeamsProvider);
        ref.invalidate(teamBoardsProvider(teamId));
        ref.invalidate(teamMembersProvider(teamId));
        if (done != null && context.mounted) showInfoSnack(context, done);
      } catch (e) {
        if (context.mounted) showErrorSnack(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('チーム管理')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ---------------- チーム ----------------
          _Section(
            title: 'チーム',
            actions: [
              OutlinedButton.icon(
                onPressed: () async {
                  final id = await showCreateTeamDialog(context, ref);
                  if (id != null && context.mounted) context.go(AppRoutes.board);
                },
                icon: const Icon(Icons.group_add),
                label: const Text('新しいチームを作成'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.join),
                icon: const Icon(Icons.vpn_key),
                label: const Text('招待で参加'),
              ),
            ],
            children: [
              for (final t in teams)
                ListTile(
                  leading: Icon(t.teamId == teamId ? Icons.radio_button_checked : Icons.radio_button_off),
                  title: Text(t.name),
                  subtitle: t.description == null ? null : Text(t.description!),
                  onTap: () => run(() => ref.read(currentSelectionProvider.notifier).selectTeam(t.teamId)),
                  trailing: t.teamId == teamId && isOwner
                      ? IconButton(
                          tooltip: 'チーム情報を編集',
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final name = await inputDialog(
                              context,
                              title: 'チーム名を変更',
                              initial: t.name,
                            );
                            if (name == null) return;
                            if (!context.mounted) return;
                            final desc = await inputDialog(
                              context,
                              title: '説明を変更',
                              initial: t.description ?? '',
                              maxLength: 200,
                              multiline: true,
                              required: false,
                            );
                            await run(
                              () => repo.updateTeam(t.teamId, name: name, description: desc),
                              done: 'チーム情報を更新しました',
                            );
                          },
                        )
                      : null,
                ),
            ],
          ),

          // ---------------- ボード ----------------
          _Section(
            title: 'ボード',
            actions: [
              if (isLeader)
                OutlinedButton.icon(
                  onPressed: () async {
                    final name = await inputDialog(
                      context,
                      title: 'ボードを作成',
                      label: 'ボード名（例：UI班、API班）',
                    );
                    if (name == null) return;
                    await run(() async {
                      final board = await repo.createBoard(teamId, name);
                      await ref
                          .read(currentSelectionProvider.notifier)
                          .select(teamId: teamId, boardId: board.boardId);
                    }, done: 'ボードを作成しました');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ボードを作成'),
                ),
            ],
            children: [
              for (final b in ref.watch(teamBoardsProvider(teamId)).value ?? const <Board>[])
                ListTile(
                  leading: Icon(
                    b.boardId == selection.boardId ? Icons.dashboard : Icons.dashboard_outlined,
                  ),
                  title: Text(b.name),
                  onTap: () => run(
                    () => ref
                        .read(currentSelectionProvider.notifier)
                        .select(teamId: teamId, boardId: b.boardId),
                  ),
                  trailing: isLeader
                      ? IconButton(
                          tooltip: '名前を変更',
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final name = await inputDialog(
                              context,
                              title: 'ボード名を変更',
                              initial: b.name,
                            );
                            if (name == null) return;
                            await run(() => repo.renameBoard(b.boardId, name));
                          },
                        )
                      : null,
                ),
            ],
          ),

          // ---------------- メンバー ----------------
          _Section(
            title: 'メンバー',
            actions: [
              if (isLeader)
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final invite = await repo.createInvite(teamId);
                      if (context.mounted) await showInviteResultDialog(context, invite);
                    } catch (e) {
                      if (context.mounted) showErrorSnack(context, e);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('招待を発行'),
                ),
            ],
            children: [
              for (final m in (ref.watch(teamMembersProvider(teamId)).value ?? const <TeamMember>[])
                  .where((m) => m.isActive))
                ListTile(
                  leading: UserAvatar(profile: m.profile, size: 32),
                  title: Text(
                    '${m.displayName}${m.userId == uid ? '（あなた）' : ''}'
                    '${m.userId == team?.ownerUserId ? '（作成者）' : ''}',
                  ),
                  subtitle: Text(m.profile?.email ?? ''),
                  trailing: isLeader && m.userId != team?.ownerUserId
                      ? DropdownButton<TeamRole>(
                          value: m.role,
                          items: [
                            for (final r in TeamRole.values)
                              DropdownMenuItem(value: r, child: Text(r.label)),
                          ],
                          onChanged: (r) {
                            if (r == null || r == m.role) return;
                            run(() => repo.changeRole(teamId, m.userId, r), done: 'ロールを変更しました');
                          },
                        )
                      : Text(m.role.label),
                ),
            ],
          ),

          // ---------------- 退出・削除 ----------------
          _Section(
            title: 'その他',
            children: [
              if (!isOwner)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('このチームから退出する'),
                  onTap: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'チームから退出',
                      message: '「${team?.name ?? ''}」から退出します。招待されれば再参加できます。',
                      okLabel: '退出',
                      danger: true,
                    );
                    if (!ok) return;
                    await run(() => repo.leaveTeam(teamId), done: 'チームから退出しました');
                    ref.read(currentSelectionProvider.notifier).clear();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                ),
              if (isOwner)
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                  title: const Text('このチームを削除する（作成者のみ）'),
                  subtitle: const Text('作成者は退出できません。チームを離れるには削除してください。'),
                  onTap: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'チームを削除',
                      message: '「${team?.name ?? ''}」を削除します。メンバー全員がこのチームを見られなくなります。',
                      okLabel: '削除',
                      danger: true,
                    );
                    if (!ok) return;
                    await run(() => repo.deleteTeam(teamId), done: 'チームを削除しました');
                    ref.read(currentSelectionProvider.notifier).clear();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.actions = const []});

  final String title;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Wrap(spacing: 8, children: actions),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
