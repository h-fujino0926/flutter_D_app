// DB のテーブルに対応するモデル（freezed + json_serializable）。
// JSON のキーは build.yaml の設定で snake_case に自動変換される。
// 変更したら次のコマンドで再生成する：
//   dart run build_runner build --delete-conflicting-outputs
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

export 'enums.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// profiles
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String displayName,
    required String email,
    @Default('#F4A261') String iconColor,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

/// user_settings
@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    int? lastTeamId,
    int? lastBoardId,
    @Default(true) bool miniWindowEnabled,
    @Default(false) bool googleCalendarLinked,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// teams
@freezed
abstract class Team with _$Team {
  const factory Team({
    required int teamId,
    required String name,
    String? description,
    required String ownerUserId,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

/// team_members（profiles を埋め込んで取得する）
@freezed
abstract class TeamMember with _$TeamMember {
  const TeamMember._();

  const factory TeamMember({
    required int teamMemberId,
    required int teamId,
    required String userId,
    required TeamRole role,
    DateTime? leftAt,
    @JsonKey(name: 'profiles') Profile? profile,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);

  bool get isActive => leftAt == null;
  bool get isLeader => role == TeamRole.leader;
  String get displayName => profile?.displayName ?? '（不明なユーザー）';
}

/// boards
@freezed
abstract class Board with _$Board {
  const factory Board({
    required int boardId,
    required int teamId,
    required String name,
  }) = _Board;

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
}

/// task_members（担当者）
@freezed
abstract class TaskAssignee with _$TaskAssignee {
  const factory TaskAssignee({
    required int taskMemberId,
    required String userId,
  }) = _TaskAssignee;

  factory TaskAssignee.fromJson(Map<String, dynamic> json) =>
      _$TaskAssigneeFromJson(json);
}

/// tasks（付箋）
@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required int taskId,
    required int teamId,
    required int boardId,
    required String title,
    String? description,
    DateTime? startAt,
    @Default(false) bool startHasTime,
    DateTime? dueAt,
    @Default(false) bool dueHasTime,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(TaskStatus.todo) TaskStatus status,
    @Default(0) double posX,
    @Default(0) double posY,
    @Default('#FFF59D') String color,
    @Default(TaskSize.m) TaskSize size,
    String? latestComment,
    String? latestCommentBy,
    DateTime? latestCommentAt,
    required String createdBy,
    DateTime? completedAt,
    String? completedBy,
    DateTime? reviewedAt,
    DateTime? returnedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'task_members') @Default([]) List<TaskAssignee> assignees,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  List<String> get assigneeIds => [for (final a in assignees) a.userId];
  bool get isReturned => returnedAt != null;
  bool get isDeleted => deletedAt != null;
  bool get isReviewed => reviewedAt != null;
}

/// get_my_tasks() の1行（ミニウィンドウ・スマホ・右パネル用）
@freezed
abstract class MyTask with _$MyTask {
  const factory MyTask({
    required int taskId,
    required int teamId,
    required String teamName,
    required int boardId,
    required String boardName,
    required String title,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? startAt,
    @Default(false) bool startHasTime,
    DateTime? dueAt,
    @Default(false) bool dueHasTime,
    @Default('#FFF59D') String color,
    String? latestComment,
    DateTime? returnedAt,
  }) = _MyTask;

  factory MyTask.fromJson(Map<String, dynamic> json) => _$MyTaskFromJson(json);
}

/// task_status_history
@freezed
abstract class StatusHistory with _$StatusHistory {
  const factory StatusHistory({
    required int historyId,
    required int taskId,
    String? userId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    String? comment,
    required DateTime createdAt,
  }) = _StatusHistory;

  factory StatusHistory.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryFromJson(json);
}

/// notifications
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int notificationId,
    required String recipientUserId,
    String? actorUserId,
    int? teamId,
    int? taskId,
    required NotificationType type,
    required String message,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
