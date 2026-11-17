import 'package:flutter/material.dart';

import '../../../../core/models/models.dart';
import '../../../../core/ui/colors.dart';
import '../../../../core/ui/user_avatar.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/task_repository.dart';

/// 付箋の入力フォーム（P1-04 作成／P1-03 詳細の編集で共通）。
///
/// 親から `GlobalKey<TaskFormState>` で [TaskFormState.buildDraft] を呼んで値を取り出す。
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.members,
    this.initial,
    this.enabled = true,
  });

  /// 担当者として選べるメンバー（退出していない人）
  final List<TeamMember> members;
  final Task? initial;
  final bool enabled;

  @override
  State<TaskForm> createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title ?? '');
  late final _description = TextEditingController(text: widget.initial?.description ?? '');
  late DateTime? _startAt = widget.initial?.startAt?.toLocal();
  late bool _startHasTime = widget.initial?.startHasTime ?? false;
  late DateTime? _dueAt = widget.initial?.dueAt?.toLocal();
  late bool _dueHasTime = widget.initial?.dueHasTime ?? false;
  late TaskPriority _priority = widget.initial?.priority ?? TaskPriority.medium;
  late String _color = widget.initial?.color ?? stickyColorPresets.first;
  late TaskSize _size = widget.initial?.size ?? TaskSize.m;
  late final Set<String> _assignees = {...?widget.initial?.assigneeIds};
  String? _dateError;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  /// 入力内容を検証して TaskDraft を返す（エラーがあれば null）
  TaskDraft? buildDraft() {
    final valid = _formKey.currentState!.validate();
    final start = _startAt;
    final due = _dueAt;
    // 開始 > 締切 はエラー（DB の CHECK 制約でも防いでいる）
    final dateError = (start != null && due != null && start.isAfter(due))
        ? '開始日時は締切日時より前にしてください'
        : null;
    setState(() => _dateError = dateError);
    if (!valid || dateError != null) return null;
    return TaskDraft(
      title: _title.text,
      description: _description.text,
      startAt: start,
      startHasTime: _startHasTime,
      dueAt: due,
      dueHasTime: _dueHasTime,
      priority: _priority,
      color: _color,
      size: _size,
      assigneeIds: _assignees.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            enabled: enabled,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'タイトル（必須）'),
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'タイトルを入力してください' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _description,
            enabled: enabled,
            maxLength: 1000,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '詳細'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DateTimeField(
                  label: '開始',
                  value: _startAt,
                  hasTime: _startHasTime,
                  enabled: enabled,
                  onChanged: (v, hasTime) => setState(() {
                    _startAt = v;
                    _startHasTime = hasTime;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateTimeField(
                  label: '締切',
                  value: _dueAt,
                  hasTime: _dueHasTime,
                  enabled: enabled,
                  onChanged: (v, hasTime) => setState(() {
                    _dueAt = v;
                    _dueHasTime = hasTime;
                  }),
                ),
              ),
            ],
          ),
          if (_dateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _dateError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Labeled(
                label: '優先度',
                child: SegmentedButton<TaskPriority>(
                  segments: [
                    for (final p in TaskPriority.values)
                      ButtonSegment(value: p, label: Text(p.label)),
                  ],
                  selected: {_priority},
                  onSelectionChanged: enabled
                      ? (s) => setState(() => _priority = s.first)
                      : null,
                ),
              ),
              _Labeled(
                label: 'サイズ',
                child: SegmentedButton<TaskSize>(
                  segments: [
                    for (final s in TaskSize.values)
                      ButtonSegment(value: s, label: Text(s.label)),
                  ],
                  selected: {_size},
                  onSelectionChanged: enabled ? (s) => setState(() => _size = s.first) : null,
                ),
              ),
              _Labeled(
                label: '色',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in stickyColorPresets)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: enabled ? () => setState(() => _color = c) : null,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colorFromHex(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == c ? Colors.black87 : Colors.black12,
                                width: _color == c ? 2.5 : 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Labeled(
            label: '担当者（複数選択可・未割り当ても可）',
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final m in widget.members)
                  FilterChip(
                    avatar: UserAvatar(profile: m.profile, size: 22),
                    label: Text(m.displayName),
                    selected: _assignees.contains(m.userId),
                    onSelected: enabled
                        ? (on) => setState(
                            () => on ? _assignees.add(m.userId) : _assignees.remove(m.userId),
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 4),
      child,
    ],
  );
}

/// 日付＋時刻（任意）の入力欄。時刻を指定しないとその日の 23:59 扱い（F1）。
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.hasTime,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final bool hasTime;
  final bool enabled;
  final void Function(DateTime? value, bool hasTime) onChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    final v = value;
    onChanged(
      hasTime && v != null
          ? combineDateTime(picked, hour: v.hour, minute: v.minute)
          : endOfDay(picked),
      hasTime && v != null,
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final v = value;
    if (v == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: hasTime ? TimeOfDay.fromDateTime(v) : const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;
    onChanged(combineDateTime(v, hour: picked.hour, minute: picked.minute), true);
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    return InputDecorator(
      decoration: InputDecoration(labelText: label, enabled: enabled),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: enabled ? () => _pickDate(context) : null,
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              child: Text(v == null ? '未設定' : formatDue(v, hasTime: hasTime)),
            ),
          ),
          if (v != null) ...[
            IconButton(
              tooltip: hasTime ? '時刻を変更' : '時刻を指定',
              onPressed: enabled ? () => _pickTime(context) : null,
              icon: Icon(hasTime ? Icons.schedule : Icons.more_time),
            ),
            if (hasTime)
              IconButton(
                tooltip: '時刻を外す（23:59 扱い）',
                onPressed: enabled ? () => onChanged(endOfDay(v), false) : null,
                icon: const Icon(Icons.timer_off_outlined),
              ),
            IconButton(
              tooltip: 'クリア',
              onPressed: enabled ? () => onChanged(null, false) : null,
              icon: const Icon(Icons.clear),
            ),
          ],
        ],
      ),
    );
  }
}
