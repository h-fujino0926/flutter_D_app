import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/models.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/task_repository.dart';

part 'my_tasks_controller.g.dart';

/// 所属する全チームの「自分の担当・未完了」タスク（get_my_tasks）。
/// 右パネル（現在のチームで絞る）・ミニウィンドウ・スマホで使う。
///
/// 全チーム分をリアルタイム購読すると接続・メッセージが増えるので、
///   ・自分宛ての通知や担当変更を受け取ったとき
///   ・開いているボードで変更があったとき
///   ・60秒ごと
/// に取り直す方式にしている。
@Riverpod(keepAlive: true)
class MyTasks extends _$MyTasks {
  Timer? _timer;
  Timer? _debounce;

  @override
  Future<List<MyTask>> build() async {
    final uid = ref.watch(currentUserIdProvider);
    _timer?.cancel();
    _debounce?.cancel();
    ref.onDispose(() {
      _timer?.cancel();
      _debounce?.cancel();
    });
    if (uid == null) return const [];
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => unawaited(refresh()));
    return ref.read(taskRepositoryProvider).fetchMyTasks();
  }

  /// 取り直す（失敗しても今の表示は残す）
  Future<void> refresh() async {
    if (ref.read(currentUserIdProvider) == null) return;
    try {
      state = AsyncData(await ref.read(taskRepositoryProvider).fetchMyTasks());
    } catch (_) {
      // 通信エラー時は次の機会に取り直す
    }
  }

  /// 連続した変更をまとめて1回だけ取り直す
  void refreshSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () => unawaited(refresh()));
  }

  void removeLocal(int taskId) {
    final list = state.value;
    if (list == null) return;
    state = AsyncData([
      for (final t in list)
        if (t.taskId != taskId) t,
    ]);
  }
}
