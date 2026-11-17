import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/models/models.dart';
import '../../../core/ui/colors.dart';
import '../../../core/ui/feedback.dart';
import '../../board/application/board_controller.dart';
import '../../task/application/my_tasks_controller.dart';
import '../../task/application/task_providers.dart';
import '../../task/data/task_repository.dart';
import '../../task/presentation/task_detail_dialog.dart';

/// P1-05 カレンダー表示（機能11）
///
/// 月表示で、日付ごとに締切のある付箋（チーム内の全ボード・未完了）を表示する。
/// 付箋を別の日にドラッグして落とすと締切日が変わる（時刻はそのまま：G3）。
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key, required this.teamId, required this.boardId});

  final int teamId;
  final int boardId;

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();

  Map<DateTime, List<Task>> _group(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (final t in tasks) {
      final d = t.dueAt!.toLocal();
      map.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(t);
    }
    return map;
  }

  Future<void> _moveDue(Task task, DateTime day) async {
    final perms = ref.read(taskPermissionsProvider(widget.teamId)).value;
    if (!(perms?.canEdit(task) ?? false)) {
      showInfoSnack(context, 'この付箋の締切を変更する権限がありません');
      return;
    }
    final old = task.dueAt!.toLocal();
    final newDue = DateTime(day.year, day.month, day.day, old.hour, old.minute, old.second);
    final start = task.startAt?.toLocal();
    if (start != null && start.isAfter(newDue)) {
      showInfoSnack(context, '開始日時より前の日には移動できません');
      return;
    }
    try {
      await ref.read(taskRepositoryProvider).updateDue(task.taskId, newDue);
      ref.invalidate(teamDueTasksProvider(widget.teamId));
      ref.read(myTasksProvider.notifier).refreshSoon();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 開いているボードで変更があったらカレンダーも取り直す
    ref.listen(boardTasksProvider(widget.boardId), (_, _) {
      ref.invalidate(teamDueTasksProvider(widget.teamId));
    });
    final async = ref.watch(teamDueTasksProvider(widget.teamId));
    final byDay = _group(async.value ?? const []);

    Widget cell(DateTime day, {bool today = false, bool outside = false}) {
      final key = DateTime(day.year, day.month, day.day);
      final tasks = byDay[key] ?? const <Task>[];
      return DragTarget<Task>(
        onWillAcceptWithDetails: (d) => !isSameDay(d.data.dueAt!.toLocal(), day),
        onAcceptWithDetails: (d) => _moveDue(d.data, day),
        builder: (context, candidate, _) => Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty
                ? Colors.amber.withValues(alpha: 0.3)
                : today
                ? Colors.amber.withValues(alpha: 0.12)
                : Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: today ? FontWeight.bold : FontWeight.normal,
                  color: outside ? Colors.black26 : Colors.black87,
                ),
              ),
              for (final t in tasks.take(3))
                Draggable<Task>(
                  data: t,
                  feedback: Material(
                    elevation: 4,
                    color: colorFromHex(t.color),
                    child: Padding(padding: const EdgeInsets.all(6), child: Text(t.title)),
                  ),
                  childWhenDragging: const SizedBox(height: 18),
                  child: GestureDetector(
                    onTap: () => showTaskDetailDialog(context, taskId: t.taskId),
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: colorFromHex(t.color),
                      child: Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
              if (tasks.length > 3)
                Text('他 ${tasks.length - 3} 件', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (async.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: TableCalendar<Task>(
            locale: 'ja_JP',
            firstDay: DateTime(DateTime.now().year - 2),
            lastDay: DateTime(DateTime.now().year + 5, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            shouldFillViewport: true,
            availableCalendarFormats: const {CalendarFormat.month: '月'},
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            eventLoader: (day) => byDay[DateTime(day.year, day.month, day.day)] ?? const [],
            onPageChanged: (d) => setState(() => _focusedDay = d),
            calendarBuilders: CalendarBuilders<Task>(
              defaultBuilder: (context, day, _) => cell(day),
              todayBuilder: (context, day, _) => cell(day, today: true),
              outsideBuilder: (context, day, _) => cell(day, outside: true),
              // 標準のイベントの点は使わない（セルの中に付箋を出しているため）
              markerBuilder: (context, day, events) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
