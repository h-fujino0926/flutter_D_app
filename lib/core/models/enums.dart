import 'package:json_annotation/json_annotation.dart';

/// チーム内のロール（DB: team_role）
enum TeamRole {
  @JsonValue('leader')
  leader('リーダー'),
  @JsonValue('member')
  member('メンバー');

  const TeamRole(this.label);
  final String label;

  String get dbValue => name;
}

/// タスクの状態（DB: task_status）
enum TaskStatus {
  @JsonValue('todo')
  todo('未着手'),
  @JsonValue('in_progress')
  inProgress('進行中'),
  @JsonValue('done')
  done('完了');

  const TaskStatus(this.label);
  final String label;

  String get dbValue => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.done => 'done',
  };
}

/// 優先度（DB: task_priority）。表示は 高・中・低。
enum TaskPriority {
  @JsonValue('high')
  high('高'),
  @JsonValue('medium')
  medium('中'),
  @JsonValue('low')
  low('低');

  const TaskPriority(this.label);
  final String label;

  String get dbValue => name;
}

/// 付箋のサイズ（DB: task_size）
enum TaskSize {
  @JsonValue('S')
  s('S', 140),
  @JsonValue('M')
  m('M', 170),
  @JsonValue('L')
  l('L', 210);

  const TaskSize(this.label, this.width);
  final String label;

  /// キャンバス上の幅（論理px）。高さは幅の 0.85 倍。
  final double width;
  double get height => width * 0.85;

  String get dbValue => label;
}

/// 通知の種類（DB: notification_type）
enum NotificationType {
  @JsonValue('task_completed')
  taskCompleted,
  @JsonValue('task_returned')
  taskReturned,
  @JsonValue('task_approved')
  taskApproved,
  @JsonValue('message_updated')
  messageUpdated,
  @JsonValue('task_assigned')
  taskAssigned,
}
