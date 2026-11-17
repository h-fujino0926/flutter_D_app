import 'package:flutter_d_app/core/models/models.dart';
import 'package:flutter_d_app/core/utils/date_utils.dart';
import 'package:flutter_d_app/features/board/domain/canvas_layout.dart';
import 'package:flutter_d_app/features/invite/presentation/join_page.dart';
import 'package:flutter_d_app/features/task/domain/task_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

Task _task({
  required String createdBy,
  List<String> assignees = const [],
  double x = 0,
  double y = 0,
}) => Task(
  taskId: 1,
  teamId: 1,
  boardId: 1,
  title: 't',
  createdBy: createdBy,
  posX: x,
  posY: y,
  assignees: [
    for (var i = 0; i < assignees.length; i++)
      TaskAssignee(taskMemberId: i + 1, userId: assignees[i]),
  ],
);

void main() {
  group('TaskPermissions（DB の can_edit_task と同じルール）', () {
    const member = TaskPermissions(myUserId: 'me', isLeader: false);
    const leader = TaskPermissions(myUserId: 'me', isLeader: true);

    test('担当者は編集できる', () {
      expect(member.canEdit(_task(createdBy: 'other', assignees: ['me'])), isTrue);
    });
    test('担当者を他人にした作成者は編集できない', () {
      expect(member.canEdit(_task(createdBy: 'me', assignees: ['other'])), isFalse);
    });
    test('担当者がいなければ作成者は編集・削除できる', () {
      final t = _task(createdBy: 'me');
      expect(member.canEdit(t), isTrue);
      expect(member.canDelete(t), isTrue);
    });
    test('担当者でも作成者でなければ削除できない', () {
      expect(member.canDelete(_task(createdBy: 'other', assignees: ['me'])), isFalse);
    });
    test('リーダーは何でもできる', () {
      final t = _task(createdBy: 'other', assignees: ['other']);
      expect(leader.canEdit(t), isTrue);
      expect(leader.canDelete(t), isTrue);
      expect(leader.canReview, isTrue);
      expect(member.canReview, isFalse);
    });
  });

  group('締切の判定', () {
    final now = DateTime(2026, 11, 17, 12);
    test('24時間以内は「まもなく」', () {
      expect(dueStateOf(DateTime(2026, 11, 18, 11), now: now), DueState.soon);
    });
    test('過ぎていたら「期限切れ」', () {
      expect(dueStateOf(DateTime(2026, 11, 17, 11), now: now), DueState.overdue);
    });
    test('時刻なしはその日の 23:59:59', () {
      expect(endOfDay(DateTime(2026, 11, 17, 8)), DateTime(2026, 11, 17, 23, 59, 59));
    });
  });

  group('招待URLの解析', () {
    test('URL から token を取り出す', () {
      expect(parseInviteToken('fusenapp://join?token=abcdef0123456789'), 'abcdef0123456789');
    });
    test('token だけ貼り付けても OK', () {
      expect(parseInviteToken(' 0123456789abcdef0123 '), '0123456789abcdef0123');
    });
    test('関係ない文字列は null', () {
      expect(parseInviteToken('hello'), isNull);
    });
  });

  group('キャンバス', () {
    test('空いている位置は既存の付箋と重ならない', () {
      final existing = [_task(createdBy: 'a', x: 24, y: 24)];
      final pos = findFreePosition(existing);
      expect(pos, isNot(const Offset(24, 24)));
    });
    test('傾きは task_id ごとに毎回同じで ±2° 以内', () {
      expect(tiltRadiansOf(42), tiltRadiansOf(42));
      for (var id = 1; id < 200; id++) {
        expect(tiltRadiansOf(id).abs(), lessThanOrEqualTo(2 * 3.1416 / 180));
      }
    });
    test('付箋はキャンバスの外に出ない', () {
      final p = clampToCanvas(const Offset(-50, 99999), TaskSize.m);
      expect(p.dx, 0);
      expect(p.dy, kCanvasHeight - TaskSize.m.height);
    });
  });

  test('DB の JSON（snake_case）から Task を作れる', () {
    final task = Task.fromJson({
      'task_id': 5,
      'team_id': 1,
      'board_id': 2,
      'title': 'テスト',
      'status': 'in_progress',
      'priority': 'high',
      'size': 'L',
      'pos_x': 10,
      'pos_y': 20.5,
      'created_by': 'u1',
      'due_at': '2026-11-20T09:00:00+00:00',
      'due_has_time': true,
      'task_members': [
        {'task_member_id': 9, 'user_id': 'u2'},
      ],
    });
    expect(task.status, TaskStatus.inProgress);
    expect(task.priority, TaskPriority.high);
    expect(task.size, TaskSize.l);
    expect(task.posX, 10.0);
    expect(task.assigneeIds, ['u2']);
    expect(task.dueAt!.isUtc, isTrue);
  });
}
