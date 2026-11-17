// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
///
/// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
///   ・presence：今このボードを見ている人
/// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。

@ProviderFor(BoardTasks)
final boardTasksProvider = BoardTasksFamily._();

/// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
///
/// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
///   ・presence：今このボードを見ている人
/// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。
final class BoardTasksProvider
    extends $AsyncNotifierProvider<BoardTasks, Map<int, Task>> {
  /// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
  ///
  /// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
  ///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
  ///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
  ///   ・presence：今このボードを見ている人
  /// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。
  BoardTasksProvider._({
    required BoardTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'boardTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardTasksHash();

  @override
  String toString() {
    return r'boardTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BoardTasks create() => BoardTasks();

  @override
  bool operator ==(Object other) {
    return other is BoardTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardTasksHash() => r'504b6b3ef19b91ed7515fa126d7c139059dc7cd1';

/// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
///
/// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
///   ・presence：今このボードを見ている人
/// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。

final class BoardTasksFamily extends $Family
    with
        $ClassFamilyOverride<
          BoardTasks,
          AsyncValue<Map<int, Task>>,
          Map<int, Task>,
          FutureOr<Map<int, Task>>,
          int
        > {
  BoardTasksFamily._()
    : super(
        retry: null,
        name: r'boardTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
  ///
  /// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
  ///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
  ///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
  ///   ・presence：今このボードを見ている人
  /// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。

  BoardTasksProvider call(int boardId) =>
      BoardTasksProvider._(argument: boardId, from: this);

  @override
  String toString() => r'boardTasksProvider';
}

/// ボード上の付箋（未削除・未完了）と、そのリアルタイム同期。
///
/// ボードを開いている間だけ `board:{board_id}` という1本のチャンネルを購読する：
///   ・postgres_changes：tasks / task_members の変更 → 状態を更新
///   ・broadcast `drag`：ドラッグ中の位置（100ms に1回まで）
///   ・presence：今このボードを見ている人
/// 画面を離れると（provider が破棄されると）removeChannel で購読を解除する。

abstract class _$BoardTasks extends $AsyncNotifier<Map<int, Task>> {
  late final _$args = ref.$arg as int;
  int get boardId => _$args;

  FutureOr<Map<int, Task>> build(int boardId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Map<int, Task>>, Map<int, Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<int, Task>>, Map<int, Task>>,
              AsyncValue<Map<int, Task>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 他の人がドラッグ中の付箋（task_id → 位置）

@ProviderFor(RemoteDrags)
final remoteDragsProvider = RemoteDragsFamily._();

/// 他の人がドラッグ中の付箋（task_id → 位置）
final class RemoteDragsProvider
    extends $NotifierProvider<RemoteDrags, Map<int, RemoteDrag>> {
  /// 他の人がドラッグ中の付箋（task_id → 位置）
  RemoteDragsProvider._({
    required RemoteDragsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'remoteDragsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteDragsHash();

  @override
  String toString() {
    return r'remoteDragsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RemoteDrags create() => RemoteDrags();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, RemoteDrag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, RemoteDrag>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteDragsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteDragsHash() => r'b4f951396db14db7c86242e05c684cfdbfc19130';

/// 他の人がドラッグ中の付箋（task_id → 位置）

final class RemoteDragsFamily extends $Family
    with
        $ClassFamilyOverride<
          RemoteDrags,
          Map<int, RemoteDrag>,
          Map<int, RemoteDrag>,
          Map<int, RemoteDrag>,
          int
        > {
  RemoteDragsFamily._()
    : super(
        retry: null,
        name: r'remoteDragsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 他の人がドラッグ中の付箋（task_id → 位置）

  RemoteDragsProvider call(int boardId) =>
      RemoteDragsProvider._(argument: boardId, from: this);

  @override
  String toString() => r'remoteDragsProvider';
}

/// 他の人がドラッグ中の付箋（task_id → 位置）

abstract class _$RemoteDrags extends $Notifier<Map<int, RemoteDrag>> {
  late final _$args = ref.$arg as int;
  int get boardId => _$args;

  Map<int, RemoteDrag> build(int boardId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<int, RemoteDrag>, Map<int, RemoteDrag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, RemoteDrag>, Map<int, RemoteDrag>>,
              Map<int, RemoteDrag>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 今このボードを見ているメンバー（presence）

@ProviderFor(BoardViewers)
final boardViewersProvider = BoardViewersFamily._();

/// 今このボードを見ているメンバー（presence）
final class BoardViewersProvider
    extends $NotifierProvider<BoardViewers, Set<String>> {
  /// 今このボードを見ているメンバー（presence）
  BoardViewersProvider._({
    required BoardViewersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'boardViewersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardViewersHash();

  @override
  String toString() {
    return r'boardViewersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BoardViewers create() => BoardViewers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BoardViewersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardViewersHash() => r'bd50fe5e382a640967655e992589f20e8931f3f7';

/// 今このボードを見ているメンバー（presence）

final class BoardViewersFamily extends $Family
    with
        $ClassFamilyOverride<
          BoardViewers,
          Set<String>,
          Set<String>,
          Set<String>,
          int
        > {
  BoardViewersFamily._()
    : super(
        retry: null,
        name: r'boardViewersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 今このボードを見ているメンバー（presence）

  BoardViewersProvider call(int boardId) =>
      BoardViewersProvider._(argument: boardId, from: this);

  @override
  String toString() => r'boardViewersProvider';
}

/// 今このボードを見ているメンバー（presence）

abstract class _$BoardViewers extends $Notifier<Set<String>> {
  late final _$args = ref.$arg as int;
  int get boardId => _$args;

  Set<String> build(int boardId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
