import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../team/application/team_providers.dart';
import '../data/task_repository.dart';
import '../domain/task_permissions.dart';

part 'task_providers.g.dart';

/// チーム内での自分の操作権限
@riverpod
Future<TaskPermissions> taskPermissions(Ref ref, int teamId) async {
  final me = await ref.watch(myMembershipProvider(teamId).future);
  return TaskPermissions(
    myUserId: ref.watch(currentUserIdProvider),
    isLeader: me?.isLeader ?? false,
  );
}

/// user_id → メンバー（アイコン表示用。退出済みも含む）
@riverpod
Future<Map<String, TeamMember>> memberMap(Ref ref, int teamId) async {
  final members = await ref.watch(teamMembersProvider(teamId).future);
  return {for (final m in members) m.userId: m};
}

/// ゴミ箱（P1-07）
@riverpod
Future<List<Task>> trashTasks(Ref ref, int teamId) =>
    ref.watch(taskRepositoryProvider).fetchTrash(teamId);

/// 完了ログ（P1-07）
@riverpod
Future<List<Task>> completedTasks(Ref ref, int teamId) =>
    ref.watch(taskRepositoryProvider).fetchCompleted(teamId);

/// カレンダー用：チームの締切付きの付箋（P1-05）
@riverpod
Future<List<Task>> teamDueTasks(Ref ref, int teamId) =>
    ref.watch(taskRepositoryProvider).fetchTeamTasksWithDue(teamId);

/// 付箋のステータス履歴
@riverpod
Future<List<StatusHistory>> taskHistory(Ref ref, int taskId) =>
    ref.watch(taskRepositoryProvider).fetchHistory(taskId);
