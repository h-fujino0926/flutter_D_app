import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../data/team_repository.dart';

part 'team_providers.g.dart';

/// 参加中のチーム一覧（機能20）
@riverpod
Future<List<Team>> myTeams(Ref ref) {
  ref.watch(currentUserIdProvider); // ログインし直したら取り直す
  return ref.watch(teamRepositoryProvider).fetchMyTeams();
}

/// チームのボード一覧
@riverpod
Future<List<Board>> teamBoards(Ref ref, int teamId) =>
    ref.watch(teamRepositoryProvider).fetchBoards(teamId);

/// チームのメンバー一覧（退出済みを含む）
@riverpod
Future<List<TeamMember>> teamMembers(Ref ref, int teamId) =>
    ref.watch(teamRepositoryProvider).fetchMembers(teamId);

/// 自分のプロフィール
@riverpod
Future<Profile> myProfile(Ref ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(settingsRepositoryProvider).fetchMyProfile();
}

/// 自分のユーザー設定（user_settings）
@riverpod
Future<UserSettings> userSettings(Ref ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(settingsRepositoryProvider).fetchSettings();
}

/// いま開いているチームとボード
class Selection {
  const Selection({required this.teamId, required this.boardId});
  final int teamId;
  final int boardId;
}

/// 現在のチーム・ボードの選択。変更すると user_settings にも保存する（機能18）。
@Riverpod(keepAlive: true)
class CurrentSelection extends _$CurrentSelection {
  @override
  Selection? build() {
    // ログアウト・別ユーザーでのログインで選択をリセット
    ref.watch(currentUserIdProvider);
    return null;
  }

  Future<void> select({required int teamId, required int boardId}) async {
    state = Selection(teamId: teamId, boardId: boardId);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .saveLastSelection(teamId: teamId, boardId: boardId);
    } catch (_) {
      // 保存に失敗しても画面の切り替えは続ける（次回の復元に使うだけなので）
    }
  }

  /// チームだけ指定して、そのチームの最初のボードを開く
  Future<bool> selectTeam(int teamId) async {
    final boards = await ref.read(teamRepositoryProvider).fetchBoards(teamId);
    if (boards.isEmpty) return false;
    await select(teamId: teamId, boardId: boards.first.boardId);
    return true;
  }

  void clear() => state = null;
}

/// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。
@riverpod
Future<TeamMember?> myMembership(Ref ref, int teamId) async {
  final uid = ref.watch(currentUserIdProvider);
  final members = await ref.watch(teamMembersProvider(teamId).future);
  for (final m in members) {
    if (m.userId == uid && m.isActive) return m;
  }
  return null;
}
