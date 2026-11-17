import '../../../core/models/models.dart';

/// 付箋の操作権限（UI の出し分け用）。
///
/// DB 側の private.can_edit_task / can_delete_task と同じルールにすること。
/// ※UI で隠すだけでは不十分なので、最終的なチェックは DB（RLS / RPC）が行う。
class TaskPermissions {
  const TaskPermissions({required this.myUserId, required this.isLeader});

  final String? myUserId;
  final bool isLeader;

  /// 移動・編集・ステータス変更・一言メッセージ・担当者変更
  ///   リーダー／担当者／（担当者なしなら）作成者
  bool canEdit(Task task) {
    if (myUserId == null) return false;
    if (isLeader) return true;
    if (task.assigneeIds.contains(myUserId)) return true;
    return task.assignees.isEmpty && task.createdBy == myUserId;
  }

  /// 削除・ゴミ箱からの復元：リーダー／（作成者かつ操作できる人）
  bool canDelete(Task task) {
    if (isLeader) return true;
    return task.createdBy == myUserId && canEdit(task);
  }

  /// 完了タスクの承認・差し戻し：リーダーのみ
  bool get canReview => isLeader;
}
