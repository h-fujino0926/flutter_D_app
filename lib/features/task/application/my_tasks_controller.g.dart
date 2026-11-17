// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_tasks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 所属する全チームの「自分の担当・未完了」タスク（get_my_tasks）。
/// 右パネル（現在のチームで絞る）・ミニウィンドウ・スマホで使う。
///
/// 全チーム分をリアルタイム購読すると接続・メッセージが増えるので、
///   ・自分宛ての通知や担当変更を受け取ったとき
///   ・開いているボードで変更があったとき
///   ・60秒ごと
/// に取り直す方式にしている。

@ProviderFor(MyTasks)
final myTasksProvider = MyTasksProvider._();

/// 所属する全チームの「自分の担当・未完了」タスク（get_my_tasks）。
/// 右パネル（現在のチームで絞る）・ミニウィンドウ・スマホで使う。
///
/// 全チーム分をリアルタイム購読すると接続・メッセージが増えるので、
///   ・自分宛ての通知や担当変更を受け取ったとき
///   ・開いているボードで変更があったとき
///   ・60秒ごと
/// に取り直す方式にしている。
final class MyTasksProvider
    extends $AsyncNotifierProvider<MyTasks, List<MyTask>> {
  /// 所属する全チームの「自分の担当・未完了」タスク（get_my_tasks）。
  /// 右パネル（現在のチームで絞る）・ミニウィンドウ・スマホで使う。
  ///
  /// 全チーム分をリアルタイム購読すると接続・メッセージが増えるので、
  ///   ・自分宛ての通知や担当変更を受け取ったとき
  ///   ・開いているボードで変更があったとき
  ///   ・60秒ごと
  /// に取り直す方式にしている。
  MyTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTasksHash();

  @$internal
  @override
  MyTasks create() => MyTasks();
}

String _$myTasksHash() => r'9b882567305edb033355a78e4ef586d45c0c6e27';

/// 所属する全チームの「自分の担当・未完了」タスク（get_my_tasks）。
/// 右パネル（現在のチームで絞る）・ミニウィンドウ・スマホで使う。
///
/// 全チーム分をリアルタイム購読すると接続・メッセージが増えるので、
///   ・自分宛ての通知や担当変更を受け取ったとき
///   ・開いているボードで変更があったとき
///   ・60秒ごと
/// に取り直す方式にしている。

abstract class _$MyTasks extends $AsyncNotifier<List<MyTask>> {
  FutureOr<List<MyTask>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MyTask>>, List<MyTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MyTask>>, List<MyTask>>,
              AsyncValue<List<MyTask>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
