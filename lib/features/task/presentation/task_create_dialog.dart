import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/feedback.dart';
import '../../board/application/board_controller.dart';
import '../../team/application/team_providers.dart';
import 'widgets/task_form.dart';

/// P1-04 付箋作成ダイアログ
Future<void> showTaskCreateDialog(
  BuildContext context, {
  required int teamId,
  required int boardId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _TaskCreateDialog(teamId: teamId, boardId: boardId),
  );
}

class _TaskCreateDialog extends ConsumerStatefulWidget {
  const _TaskCreateDialog({required this.teamId, required this.boardId});

  final int teamId;
  final int boardId;

  @override
  ConsumerState<_TaskCreateDialog> createState() => _TaskCreateDialogState();
}

class _TaskCreateDialogState extends ConsumerState<_TaskCreateDialog> {
  final _formKey = GlobalKey<TaskFormState>();
  bool _saving = false;

  Future<void> _save() async {
    final draft = _formKey.currentState?.buildDraft();
    if (draft == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(boardTasksProvider(widget.boardId).notifier)
          .createTask(teamId: widget.teamId, draft: draft);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(teamMembersProvider(widget.teamId));
    return AlertDialog(
      title: const Text('付箋を追加'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: members.when(
            data: (list) => TaskForm(
              key: _formKey,
              members: list.where((m) => m.isActive).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(showErrorMessageOf(e)),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('保存')),
      ],
    );
  }
}
