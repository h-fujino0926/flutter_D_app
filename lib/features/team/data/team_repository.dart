import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';

part 'team_repository.g.dart';

/// 招待の発行結果（平文のパスコードが手に入るのはこの1回だけ）
class InviteInfo {
  const InviteInfo({
    required this.invitationId,
    required this.token,
    required this.passcode,
    required this.expiresAt,
  });

  final int invitationId;
  final String token;
  final String passcode;
  final DateTime expiresAt;

  /// 招待URL（カスタムURLスキーム）
  String get url => 'fusenapp://join?token=$token';
}

/// 招待で参加した結果
class JoinResult {
  const JoinResult({required this.ok, this.teamId, this.code, this.remainingAttempts});

  final bool ok;
  final int? teamId;

  /// 失敗時のコード（INVITE_NOT_FOUND / INVITE_EXPIRED / INVITE_LIMIT / WRONG_PASSCODE）
  final String? code;
  final int? remainingAttempts;
}

/// チーム・メンバー・ボード・招待の DB 操作。
class TeamRepository {
  TeamRepository(this._client);

  final SupabaseClient _client;

  // ---------------- チーム ----------------

  /// 参加中のチーム（RLS で自分が所属するチームだけ返る）
  Future<List<Team>> fetchMyTeams() async {
    final rows = await _client
        .from('teams')
        .select()
        .isFilter('deleted_at', null)
        .order('team_id');
    return rows.map(Team.fromJson).toList();
  }

  Future<int> createTeam({required String name, String? description}) async {
    final id = await _client.rpc<int>(
      'create_team',
      params: {'p_name': name, 'p_description': description},
    );
    return id;
  }

  Future<void> updateTeam(int teamId, {required String name, String? description}) =>
      _client
          .from('teams')
          .update({'name': name, 'description': description})
          .eq('team_id', teamId);

  Future<void> deleteTeam(int teamId) =>
      _client.rpc<void>('delete_team', params: {'p_team_id': teamId});

  // ---------------- メンバー ----------------

  /// メンバー一覧（退出済みも含む。アイコン表示に使うため）
  Future<List<TeamMember>> fetchMembers(int teamId) async {
    final rows = await _client
        .from('team_members')
        .select('*, profiles(id, display_name, email, icon_color)')
        .eq('team_id', teamId)
        .order('joined_at');
    return rows.map(TeamMember.fromJson).toList();
  }

  Future<void> leaveTeam(int teamId) =>
      _client.rpc<void>('leave_team', params: {'p_team_id': teamId});

  Future<void> changeRole(int teamId, String userId, TeamRole role) =>
      _client.rpc<void>(
        'change_member_role',
        params: {'p_team_id': teamId, 'p_user_id': userId, 'p_role': role.dbValue},
      );

  // ---------------- ボード ----------------

  Future<List<Board>> fetchBoards(int teamId) async {
    final rows = await _client
        .from('boards')
        .select('board_id, team_id, name')
        .eq('team_id', teamId)
        .order('board_id');
    return rows.map(Board.fromJson).toList();
  }

  Future<Board> createBoard(int teamId, String name) async {
    final row = await _client
        .from('boards')
        .insert({'team_id': teamId, 'name': name})
        .select('board_id, team_id, name')
        .single();
    return Board.fromJson(row);
  }

  Future<void> renameBoard(int boardId, String name) =>
      _client.from('boards').update({'name': name}).eq('board_id', boardId);

  // ---------------- 招待 ----------------

  Future<InviteInfo> createInvite(int teamId, {int maxUses = 0}) async {
    final res = await _client.rpc<Map<String, dynamic>>(
      'create_invite',
      params: {'p_team_id': teamId, 'p_max_uses': maxUses},
    );
    return InviteInfo(
      invitationId: (res['invitation_id'] as num).toInt(),
      token: res['token'] as String,
      passcode: res['passcode'] as String,
      expiresAt: DateTime.parse(res['expires_at'] as String),
    );
  }

  Future<void> revokeInvite(int invitationId) =>
      _client.rpc<void>('revoke_invite', params: {'p_invitation_id': invitationId});

  Future<JoinResult> joinTeam({required String token, required String passcode}) async {
    final res = await _client.rpc<Map<String, dynamic>>(
      'join_team',
      params: {'p_token': token, 'p_passcode': passcode},
    );
    return JoinResult(
      ok: res['ok'] == true,
      teamId: (res['team_id'] as num?)?.toInt(),
      code: res['code'] as String?,
      remainingAttempts: (res['remaining_attempts'] as num?)?.toInt(),
    );
  }
}

@Riverpod(keepAlive: true)
TeamRepository teamRepository(Ref ref) => TeamRepository(ref.watch(supabaseProvider));
