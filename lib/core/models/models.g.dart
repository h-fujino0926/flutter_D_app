// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  email: json['email'] as String,
  iconColor: json['icon_color'] as String? ?? '#F4A261',
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'email': instance.email,
  'icon_color': instance.iconColor,
};

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      userId: json['user_id'] as String,
      lastTeamId: (json['last_team_id'] as num?)?.toInt(),
      lastBoardId: (json['last_board_id'] as num?)?.toInt(),
      miniWindowEnabled: json['mini_window_enabled'] as bool? ?? true,
      googleCalendarLinked: json['google_calendar_linked'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'last_team_id': instance.lastTeamId,
      'last_board_id': instance.lastBoardId,
      'mini_window_enabled': instance.miniWindowEnabled,
      'google_calendar_linked': instance.googleCalendarLinked,
    };

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  teamId: (json['team_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  ownerUserId: json['owner_user_id'] as String,
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'team_id': instance.teamId,
  'name': instance.name,
  'description': instance.description,
  'owner_user_id': instance.ownerUserId,
};

_TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => _TeamMember(
  teamMemberId: (json['team_member_id'] as num).toInt(),
  teamId: (json['team_id'] as num).toInt(),
  userId: json['user_id'] as String,
  role: $enumDecode(_$TeamRoleEnumMap, json['role']),
  leftAt: json['left_at'] == null
      ? null
      : DateTime.parse(json['left_at'] as String),
  profile: json['profiles'] == null
      ? null
      : Profile.fromJson(json['profiles'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TeamMemberToJson(_TeamMember instance) =>
    <String, dynamic>{
      'team_member_id': instance.teamMemberId,
      'team_id': instance.teamId,
      'user_id': instance.userId,
      'role': _$TeamRoleEnumMap[instance.role]!,
      'left_at': instance.leftAt?.toIso8601String(),
      'profiles': instance.profile?.toJson(),
    };

const _$TeamRoleEnumMap = {
  TeamRole.leader: 'leader',
  TeamRole.member: 'member',
};

_Board _$BoardFromJson(Map<String, dynamic> json) => _Board(
  boardId: (json['board_id'] as num).toInt(),
  teamId: (json['team_id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$BoardToJson(_Board instance) => <String, dynamic>{
  'board_id': instance.boardId,
  'team_id': instance.teamId,
  'name': instance.name,
};

_TaskAssignee _$TaskAssigneeFromJson(Map<String, dynamic> json) =>
    _TaskAssignee(
      taskMemberId: (json['task_member_id'] as num).toInt(),
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$TaskAssigneeToJson(_TaskAssignee instance) =>
    <String, dynamic>{
      'task_member_id': instance.taskMemberId,
      'user_id': instance.userId,
    };

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  taskId: (json['task_id'] as num).toInt(),
  teamId: (json['team_id'] as num).toInt(),
  boardId: (json['board_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  startAt: json['start_at'] == null
      ? null
      : DateTime.parse(json['start_at'] as String),
  startHasTime: json['start_has_time'] as bool? ?? false,
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  dueHasTime: json['due_has_time'] as bool? ?? false,
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.todo,
  posX: (json['pos_x'] as num?)?.toDouble() ?? 0,
  posY: (json['pos_y'] as num?)?.toDouble() ?? 0,
  color: json['color'] as String? ?? '#FFF59D',
  size: $enumDecodeNullable(_$TaskSizeEnumMap, json['size']) ?? TaskSize.m,
  latestComment: json['latest_comment'] as String?,
  latestCommentBy: json['latest_comment_by'] as String?,
  latestCommentAt: json['latest_comment_at'] == null
      ? null
      : DateTime.parse(json['latest_comment_at'] as String),
  createdBy: json['created_by'] as String,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  completedBy: json['completed_by'] as String?,
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  returnedAt: json['returned_at'] == null
      ? null
      : DateTime.parse(json['returned_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  assignees:
      (json['task_members'] as List<dynamic>?)
          ?.map((e) => TaskAssignee.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'task_id': instance.taskId,
  'team_id': instance.teamId,
  'board_id': instance.boardId,
  'title': instance.title,
  'description': instance.description,
  'start_at': instance.startAt?.toIso8601String(),
  'start_has_time': instance.startHasTime,
  'due_at': instance.dueAt?.toIso8601String(),
  'due_has_time': instance.dueHasTime,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'pos_x': instance.posX,
  'pos_y': instance.posY,
  'color': instance.color,
  'size': _$TaskSizeEnumMap[instance.size]!,
  'latest_comment': instance.latestComment,
  'latest_comment_by': instance.latestCommentBy,
  'latest_comment_at': instance.latestCommentAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'completed_at': instance.completedAt?.toIso8601String(),
  'completed_by': instance.completedBy,
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
  'returned_at': instance.returnedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'task_members': instance.assignees.map((e) => e.toJson()).toList(),
};

const _$TaskPriorityEnumMap = {
  TaskPriority.high: 'high',
  TaskPriority.medium: 'medium',
  TaskPriority.low: 'low',
};

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'todo',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.done: 'done',
};

const _$TaskSizeEnumMap = {TaskSize.s: 'S', TaskSize.m: 'M', TaskSize.l: 'L'};

_MyTask _$MyTaskFromJson(Map<String, dynamic> json) => _MyTask(
  taskId: (json['task_id'] as num).toInt(),
  teamId: (json['team_id'] as num).toInt(),
  teamName: json['team_name'] as String,
  boardId: (json['board_id'] as num).toInt(),
  boardName: json['board_name'] as String,
  title: json['title'] as String,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  startAt: json['start_at'] == null
      ? null
      : DateTime.parse(json['start_at'] as String),
  startHasTime: json['start_has_time'] as bool? ?? false,
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  dueHasTime: json['due_has_time'] as bool? ?? false,
  color: json['color'] as String? ?? '#FFF59D',
  latestComment: json['latest_comment'] as String?,
  returnedAt: json['returned_at'] == null
      ? null
      : DateTime.parse(json['returned_at'] as String),
);

Map<String, dynamic> _$MyTaskToJson(_MyTask instance) => <String, dynamic>{
  'task_id': instance.taskId,
  'team_id': instance.teamId,
  'team_name': instance.teamName,
  'board_id': instance.boardId,
  'board_name': instance.boardName,
  'title': instance.title,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'start_at': instance.startAt?.toIso8601String(),
  'start_has_time': instance.startHasTime,
  'due_at': instance.dueAt?.toIso8601String(),
  'due_has_time': instance.dueHasTime,
  'color': instance.color,
  'latest_comment': instance.latestComment,
  'returned_at': instance.returnedAt?.toIso8601String(),
};

_StatusHistory _$StatusHistoryFromJson(Map<String, dynamic> json) =>
    _StatusHistory(
      historyId: (json['history_id'] as num).toInt(),
      taskId: (json['task_id'] as num).toInt(),
      userId: json['user_id'] as String?,
      fromStatus: $enumDecode(_$TaskStatusEnumMap, json['from_status']),
      toStatus: $enumDecode(_$TaskStatusEnumMap, json['to_status']),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$StatusHistoryToJson(_StatusHistory instance) =>
    <String, dynamic>{
      'history_id': instance.historyId,
      'task_id': instance.taskId,
      'user_id': instance.userId,
      'from_status': _$TaskStatusEnumMap[instance.fromStatus]!,
      'to_status': _$TaskStatusEnumMap[instance.toStatus]!,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
    };

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      notificationId: (json['notification_id'] as num).toInt(),
      recipientUserId: json['recipient_user_id'] as String,
      actorUserId: json['actor_user_id'] as String?,
      teamId: (json['team_id'] as num?)?.toInt(),
      taskId: (json['task_id'] as num?)?.toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'notification_id': instance.notificationId,
      'recipient_user_id': instance.recipientUserId,
      'actor_user_id': instance.actorUserId,
      'team_id': instance.teamId,
      'task_id': instance.taskId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'message': instance.message,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.taskCompleted: 'task_completed',
  NotificationType.taskReturned: 'task_returned',
  NotificationType.taskApproved: 'task_approved',
  NotificationType.messageUpdated: 'message_updated',
  NotificationType.taskAssigned: 'task_assigned',
};
