import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/prefs/local_prefs.dart';
import '../../auth/data/auth_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../application/team_providers.dart';
import '../data/team_repository.dart';

/// ログイン直後の振り分け（7.1 の 3〜4、機能18）。
///   1. スマホなら閲覧専用画面へ
///   2. ログイン前に招待URLを開いていたら参加画面へ
///   3. 前回のチーム・ボードがあればそこを開く
///   4. 前回のものが無ければ、所属チームの最初のボード
///   5. チームが1つも無ければ「チーム作成／招待で参加」画面へ
class HomeResolverPage extends ConsumerStatefulWidget {
  const HomeResolverPage({super.key});

  @override
  ConsumerState<HomeResolverPage> createState() => _HomeResolverPageState();
}

class _HomeResolverPageState extends ConsumerState<HomeResolverPage> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    setState(() => _error = null);
    try {
      if (PlatformInfo.isMobile) {
        context.go(AppRoutes.mobile);
        return;
      }

      final prefs = ref.read(localPrefsProvider);
      final pendingToken = prefs.pendingInviteToken;
      if (pendingToken != null) {
        await prefs.setPendingInviteToken(null);
        if (mounted) context.go(AppRoutes.joinWithToken(pendingToken));
        return;
      }

      final settings = await ref.read(settingsRepositoryProvider).fetchSettings();
      final teams = await ref.read(teamRepositoryProvider).fetchMyTeams();
      final selection = ref.read(currentSelectionProvider.notifier);

      final lastTeam = settings.lastTeamId;
      final lastBoard = settings.lastBoardId;
      if (lastTeam != null && lastBoard != null && teams.any((t) => t.teamId == lastTeam)) {
        final boards = await ref.read(teamRepositoryProvider).fetchBoards(lastTeam);
        if (boards.any((b) => b.boardId == lastBoard)) {
          await selection.select(teamId: lastTeam, boardId: lastBoard);
          if (mounted) context.go(AppRoutes.board);
          return;
        }
      }
      for (final team in teams) {
        if (await selection.selectTeam(team.teamId)) {
          if (mounted) context.go(AppRoutes.board);
          return;
        }
      }
      if (mounted) context.go(AppRoutes.setup);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Scaffold(
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(toJapaneseMessage(error)),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _resolve, child: const Text('再読み込み')),
                  TextButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text('ログアウト'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 付箋を開く（通知・ミニウィンドウ・検索から）：その付箋のチーム・ボードに切り替えてから詳細を開く。
class OpenTaskPage extends ConsumerStatefulWidget {
  const OpenTaskPage({super.key, required this.taskId});

  final int taskId;

  @override
  ConsumerState<OpenTaskPage> createState() => _OpenTaskPageState();
}

class _OpenTaskPageState extends ConsumerState<OpenTaskPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    try {
      // 付箋のチーム・ボードを調べる（RLS で見えない付箋なら null）
      final row = await ref
          .read(settingsRepositoryProvider)
          .findTaskLocation(widget.taskId);
      if (row == null) {
        if (mounted) context.go(AppRoutes.home);
        return;
      }
      await ref
          .read(currentSelectionProvider.notifier)
          .select(teamId: row.teamId, boardId: row.boardId);
      if (mounted) context.go(AppRoutes.boardWithTask(widget.taskId));
    } catch (_) {
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
