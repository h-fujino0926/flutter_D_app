import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../core/supabase/supabase_providers.dart';
import '../../../../core/ui/colors.dart';
import '../../../../core/ui/feedback.dart';
import '../../../../core/ui/user_avatar.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../task/application/task_providers.dart';
import '../../../task/presentation/task_actions.dart';
import '../../../task/presentation/task_detail_dialog.dart';
import '../../application/board_controller.dart';
import '../../domain/canvas_layout.dart';

/// キャンバス上の付箋1枚。
///
/// パフォーマンス（非機能要件2）のため：
///   ・この付箋の状態だけを select で監視する（他の付箋が動いても再描画しない）
///   ・自分がドラッグ中の位置はこのウィジェットの中だけで持つ
///   ・RepaintBoundary で描画を分離する
class StickyNote extends ConsumerStatefulWidget {
  const StickyNote({
    super.key,
    required this.boardId,
    required this.teamId,
    required this.taskId,
  });

  final int boardId;
  final int teamId;
  final int taskId;

  @override
  ConsumerState<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends ConsumerState<StickyNote> with TickerProviderStateMixin {
  /// 自分がドラッグ中の位置（ドラッグしていなければ null）
  Offset? _dragPos;

  /// 完了時の「めくれて飛んでいく」アニメーション（0.4秒）
  late final _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  /// 締切が近いときに1回だけ揺らすアニメーション
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  bool _shakeDone = false;

  @override
  void dispose() {
    _fly.dispose();
    _shake.dispose();
    super.dispose();
  }

  BoardTasks get _controller => ref.read(boardTasksProvider(widget.boardId).notifier);

  Future<void> _complete(Task task) async {
    await _fly.forward();
    if (!mounted) return;
    await completeTaskWithUndo(
      context,
      taskId: task.taskId,
      title: task.title,
      boardId: widget.boardId,
    );
    // 失敗して付箋が戻ってきた場合に備えて、見た目を元に戻しておく
    if (mounted) _fly.reset();
  }

  void _onPanUpdate(Task task, DragUpdateDetails d) {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final next = clampToCanvas(
      (_dragPos ?? Offset(task.posX, task.posY)) + d.delta,
      task.size,
    );
    setState(() => _dragPos = next);
    _controller.sendDrag(task.taskId, next, uid);
  }

  void _onPanEnd(Task task) {
    final pos = _dragPos;
    if (pos == null) return;
    // moveTask は最初に手元の状態を書き換える（楽観的更新）ので、その後でドラッグ位置を消す
    final future = _controller.moveTask(task.taskId, pos);
    setState(() => _dragPos = null);
    future.catchError((Object e) {
      if (mounted) showErrorSnack(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(
      boardTasksProvider(widget.boardId).select((s) => s.value?[widget.taskId]),
    );
    if (task == null) return const Positioned(left: 0, top: 0, child: SizedBox.shrink());

    final remote = ref.watch(
      remoteDragsProvider(widget.boardId).select((m) => m[widget.taskId]),
    );
    final perms = ref.watch(taskPermissionsProvider(widget.teamId)).value;
    final members = ref.watch(memberMapProvider(widget.teamId)).value ?? const {};
    final canEdit = perms?.canEdit(task) ?? false;

    final dragging = _dragPos != null;
    // 自分がドラッグ中の付箋には、他人からの位置更新を適用しない（7.3 の 5）
    final pos = _dragPos ?? remote?.position ?? Offset(task.posX, task.posY);
    final due = dueStateOf(task.dueAt);

    // 締切が近い付箋は最初の表示で1回だけ揺らす
    if (due == DueState.soon && !_shakeDone) {
      _shakeDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _shake.forward();
      });
    }

    final note = RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_fly, _shake]),
        builder: (context, child) {
          final t = Curves.easeIn.transform(_fly.value);
          final shake = math.sin(_shake.value * math.pi * 6) * (1 - _shake.value) * 0.05;
          return Opacity(
            opacity: 1 - t,
            child: Transform.translate(
              offset: Offset(320 * t, -220 * t),
              child: Transform.rotate(
                angle: tiltRadiansOf(task.taskId) + shake + 0.8 * t,
                child: Transform.scale(scale: dragging ? 1.06 : 1 - 0.3 * t, child: child),
              ),
            ),
          );
        },
        child: _NoteCard(
          task: task,
          members: members,
          due: due,
          dragging: dragging,
          canEdit: canEdit,
          onToggleStatus: () async {
            final next = task.status == TaskStatus.todo ? TaskStatus.inProgress : TaskStatus.todo;
            try {
              await _controller.setStatus(task.taskId, next);
            } catch (e) {
              if (context.mounted) showErrorSnack(context, e);
            }
          },
          onComplete: () => _complete(task),
        ),
      ),
    );

    return AnimatedPositioned(
      // 他の人のドラッグは滑らかに追従させ、自分のドラッグは即座に反映する
      duration: dragging ? Duration.zero : const Duration(milliseconds: 120),
      left: pos.dx,
      top: pos.dy,
      child: MouseRegion(
        cursor: canEdit ? SystemMouseCursors.grab : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showTaskDetailDialog(context, taskId: task.taskId),
          onPanUpdate: canEdit ? (d) => _onPanUpdate(task, d) : null,
          onPanEnd: canEdit ? (_) => _onPanEnd(task) : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              note,
              // 他の人がドラッグ中なら、その人のアイコンを横に出す
              if (remote != null)
                Positioned(
                  right: -14,
                  top: -14,
                  child: UserAvatar(profile: members[remote.userId]?.profile, size: 26),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 付箋の見た目（6.3 付箋の見た目ルール）
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.task,
    required this.members,
    required this.due,
    required this.dragging,
    required this.canEdit,
    required this.onToggleStatus,
    required this.onComplete,
  });

  final Task task;
  final Map<String, TeamMember> members;
  final DueState due;
  final bool dragging;
  final bool canEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final base = colorFromHex(task.color);
    final overdue = due == DueState.overdue;
    final background = overdue ? Color.lerp(base, const Color(0xFFEF9A9A), 0.65)! : base;
    final creator = members[task.createdBy];

    return SizedBox(
      width: task.size.width,
      height: task.size.height,
      child: CustomPaint(
        // 期限切れ：右下の端がめくれたような形
        foregroundPainter: overdue ? _CurlPainter() : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: background,
            border: due == DueState.soon
                ? Border.all(color: Colors.orange, width: 3)
                : task.isReturned
                ? Border.all(color: Colors.deepOrange, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dragging ? 0.35 : 0.18),
                blurRadius: dragging ? 18 : 6,
                offset: Offset(2, dragging ? 10 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PriorityBadge(priority: task.priority),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: canEdit ? onToggleStatus : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: task.status == TaskStatus.inProgress
                            ? Colors.blue.shade600
                            : Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.status.label,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (overdue) const _Label('期限切れ', Colors.red),
                  if (due == DueState.soon) const _Label('まもなく', Colors.orange),
                  if (task.isReturned) const _Label('差し戻し', Colors.deepOrange),
                  if (canEdit)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        tooltip: '完了にする',
                        onPressed: onComplete,
                        icon: const Icon(Icons.check_circle_outline),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: task.size == TaskSize.s ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: task.size == TaskSize.l ? 15 : 13,
                  ),
                ),
              ),
              if (task.isReturned && task.latestComment != null)
                Text(
                  '💬 ${task.latestComment}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
              if (task.dueAt != null)
                Text(
                  '〆 ${formatDue(task.dueAt, hasTime: task.dueHasTime)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: overdue ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // 担当者アイコン
                  for (final a in task.assignees.take(4))
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: UserAvatar(
                        profile: members[a.userId]?.profile,
                        size: 20,
                        inactive: !(members[a.userId]?.isActive ?? true),
                      ),
                    ),
                  if (task.assignees.length > 4)
                    Text('+${task.assignees.length - 4}', style: const TextStyle(fontSize: 11)),
                  const Spacer(),
                  if (task.latestComment != null && !task.isReturned)
                    Tooltip(
                      message: task.latestComment!,
                      child: const Icon(Icons.chat_bubble_outline, size: 14),
                    ),
                  const SizedBox(width: 4),
                  // 作成者アイコン（小）
                  Opacity(
                    opacity: 0.8,
                    child: UserAvatar(profile: creator?.profile, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => Colors.red.shade400,
      TaskPriority.medium => Colors.amber.shade700,
      TaskPriority.low => Colors.green.shade500,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        priority.label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 2),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 9)),
  );
}

/// 期限切れの付箋の右下を「めくれた」ように描く
class _CurlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const curl = 22.0;
    final corner = Path()
      ..moveTo(size.width - curl, size.height)
      ..lineTo(size.width, size.height - curl)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(corner, Paint()..color = const Color(0xFFFAF7F0));
    final fold = Path()
      ..moveTo(size.width - curl, size.height)
      ..lineTo(size.width, size.height - curl)
      ..lineTo(size.width - curl, size.height - curl)
      ..close();
    canvas.drawShadow(fold, Colors.black, 2, false);
    canvas.drawPath(fold, Paint()..color = const Color(0xFFE57373));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
