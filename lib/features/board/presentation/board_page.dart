import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/models/models.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/ui/user_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../calendar/presentation/calendar_view.dart';
import '../../mini_window/application/window_mode_controller.dart';
import '../../notification/application/notifications_controller.dart';
import '../../task/application/task_providers.dart';
import '../../task/presentation/search_dialog.dart';
import '../../task/presentation/task_create_dialog.dart';
import '../../task/presentation/task_detail_dialog.dart';
import '../../team/application/team_providers.dart';
import '../application/board_controller.dart';
import 'widgets/board_canvas.dart';
import 'widgets/my_tasks_panel.dart';

/// P1-01 メイン（ボード）画面（いただいた画面イメージのレイアウト）
///   ヘッダー：設定 ／ 日付（カレンダー）／ 検索 ／ 閲覧中のメンバー ／ チーム・通知・アカウント
///   左：チームのタスク（自由配置キャンバス or カレンダー）
///   右上：［追加］［完］（完 = 完了ログ P1-07）
///   右：現在のチームのマイタスク（期限順）
class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key, this.openTaskId});

  /// ?task=ID が付いていたら、表示後にその付箋の詳細を開く
  final int? openTaskId;

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  bool _calendar = false;

  @override
  void initState() {
    super.initState();
    final taskId = widget.openTaskId;
    if (taskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // URL から ?task= を消してから詳細を開く（戻る操作で何度も開かないように）
        context.go(AppRoutes.board);
        showTaskDetailDialog(context, taskId: taskId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(currentSelectionProvider);
    if (selection == null) {
      // 選択が無い（再起動直後など）→ 振り分け画面へ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final teamId = selection.teamId;
    final boardId = selection.boardId;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BoardHeader(
              teamId: teamId,
              boardId: boardId,
              calendar: _calendar,
              onToggleCalendar: () => setState(() => _calendar = !_calendar),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Panel(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _calendar
                            ? CalendarView(teamId: teamId, boardId: boardId)
                            : BoardCanvas(teamId: teamId, boardId: boardId),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => showTaskCreateDialog(
                                  context,
                                  teamId: teamId,
                                  boardId: boardId,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('追加'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'ゴミ箱・完了ログ',
                              child: OutlinedButton(
                                onPressed: () => context.push(AppRoutes.trash),
                                child: const Text('完'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _Panel(child: MyTasksPanel(teamId: teamId))),
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

class _BoardHeader extends ConsumerWidget {
  const _BoardHeader({
    required this.teamId,
    required this.boardId,
    required this.calendar,
    required this.onToggleCalendar,
  });

  final int teamId;
  final int boardId;
  final bool calendar;
  final VoidCallback onToggleCalendar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(myTeamsProvider).value ?? const <Team>[];
    final boards = ref.watch(teamBoardsProvider(teamId)).value ?? const <Board>[];
    final team = teams.where((t) => t.teamId == teamId).firstOrNull;
    final board = boards.where((b) => b.boardId == boardId).firstOrNull;
    final unread = ref.watch(unreadCountProvider);
    final profile = ref.watch(myProfileProvider).value;
    final viewers = ref.watch(boardViewersProvider(boardId));
    final members = ref.watch(memberMapProvider(teamId)).value ?? const {};

    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings),
            label: const Text('設定'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onToggleCalendar,
            icon: Icon(calendar ? Icons.dashboard_outlined : Icons.calendar_month),
            label: Text(calendar ? 'ボード表示' : 'カレンダー'),
          ),
          IconButton(
            tooltip: '検索',
            onPressed: () => showSearchDialog(context, teamId: teamId),
            icon: const Icon(Icons.search),
          ),
          const Spacer(),
          // このボードを今見ているメンバー（presence）
          for (final uid in viewers.take(6))
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: UserAvatar(profile: members[uid]?.profile, size: 24),
            ),
          const SizedBox(width: 12),
          // チーム・ボードの切り替え（仮決定 E2：ボード選択はチームメニューの中）
          PopupMenuButton<void>(
            tooltip: 'チーム・ボードを切り替え',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.groups),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      '${team?.name ?? ''} / ${board?.name ?? ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(enabled: false, child: Text('ボード')),
              for (final b in boards)
                PopupMenuItem(
                  onTap: () => ref
                      .read(currentSelectionProvider.notifier)
                      .select(teamId: teamId, boardId: b.boardId),
                  child: Row(
                    children: [
                      Icon(b.boardId == boardId ? Icons.check : Icons.dashboard_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(b.name),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text('チーム')),
              for (final t in teams)
                PopupMenuItem(
                  onTap: () async {
                    try {
                      await ref.read(currentSelectionProvider.notifier).selectTeam(t.teamId);
                    } catch (e) {
                      if (context.mounted) showErrorSnack(context, e);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(t.teamId == teamId ? Icons.check : Icons.group_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(t.name),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () => context.push(AppRoutes.team),
                child: const Text('チーム管理（作成・メンバー・招待・ボード）'),
              ),
              PopupMenuItem(
                onTap: () => context.push(AppRoutes.join),
                child: const Text('招待で参加'),
              ),
            ],
          ),
          // 通知（未読数）
          IconButton(
            tooltip: '通知',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications),
            ),
          ),
          // アカウント
          PopupMenuButton<void>(
            tooltip: 'アカウント',
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: UserAvatar(profile: profile, size: 30),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('${profile?.displayName ?? ''}\n${profile?.email ?? ''}'),
              ),
              PopupMenuItem(
                onTap: () => context.push(AppRoutes.settings),
                child: const Text('プロフィール・設定'),
              ),
              if (PlatformInfo.isDesktop)
                PopupMenuItem(
                  onTap: () => ref.read(windowModeControllerProvider.notifier).enterMini(),
                  child: const Text('ミニウィンドウに切り替え'),
                ),
              PopupMenuItem(
                onTap: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('ログアウト'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 角丸の枠
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
