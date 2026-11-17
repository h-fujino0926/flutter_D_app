import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/models/models.dart';
import '../../../core/ui/colors.dart';
import '../../../core/ui/feedback.dart';
import '../../../core/utils/date_utils.dart';
import '../../team/application/team_providers.dart';
import '../data/task_repository.dart';

/// P1-02 検索：タイトル・担当者・ステータス・優先度で付箋を絞り込む
/// 仮決定（B11）：現在のチームの全ボードが対象。ゴミ箱は除く。
Future<void> showSearchDialog(BuildContext context, {required int teamId}) =>
    showDialog<void>(context: context, builder: (_) => _SearchDialog(teamId: teamId));

class _SearchDialog extends ConsumerStatefulWidget {
  const _SearchDialog({required this.teamId});
  final int teamId;

  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  final _keyword = TextEditingController();
  String? _assigneeId;
  TaskStatus? _status;
  TaskPriority? _priority;
  List<Task>? _results;
  bool _loading = false;

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final results = await ref
          .read(taskRepositoryProvider)
          .search(
            teamId: widget.teamId,
            keyword: _keyword.text,
            assigneeId: _assigneeId,
            status: _status,
            priority: _priority,
          );
      setState(() => _results = results);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(teamMembersProvider(widget.teamId)).value ?? const [];
    final boards = ref.watch(teamBoardsProvider(widget.teamId)).value ?? const [];
    final boardNames = {for (final b in boards) b.boardId: b.name};
    final results = _results;

    return AlertDialog(
      title: const Text('付箋を検索'),
      content: SizedBox(
        width: 640,
        height: 480,
        child: Column(
          children: [
            TextField(
              controller: _keyword,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _assigneeId,
                    decoration: const InputDecoration(labelText: '担当者'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('指定なし')),
                      for (final m in members)
                        DropdownMenuItem(value: m.userId, child: Text(m.displayName)),
                    ],
                    onChanged: (v) => setState(() => _assigneeId = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<TaskStatus?>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'ステータス'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('指定なし')),
                      for (final s in TaskStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (v) => setState(() => _status = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<TaskPriority?>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: '優先度'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('指定なし')),
                      for (final p in TaskPriority.values)
                        DropdownMenuItem(value: p, child: Text(p.label)),
                    ],
                    onChanged: (v) => setState(() => _priority = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _loading ? null : _search, child: const Text('検索')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : results == null
                  ? const Center(child: Text('条件を入れて「検索」を押してください'))
                  : results.isEmpty
                  ? const Center(child: Text('見つかりませんでした'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final t = results[i];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: colorFromHex(t.color), radius: 10),
                          title: Text(t.title),
                          subtitle: Text(
                            '${boardNames[t.boardId] ?? ''} ・ ${t.status.label} ・ 優先度${t.priority.label}'
                            '${t.dueAt == null ? '' : ' ・ 〆${formatDue(t.dueAt, hasTime: t.dueHasTime)}'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // 別のボードの付箋でも開けるように、チーム・ボードを切り替えてから開く
                            context.go(AppRoutes.openTask(t.taskId));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
      ],
    );
  }
}
