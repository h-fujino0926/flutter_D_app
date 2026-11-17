// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// チーム内での自分の操作権限

@ProviderFor(taskPermissions)
final taskPermissionsProvider = TaskPermissionsFamily._();

/// チーム内での自分の操作権限

final class TaskPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TaskPermissions>,
          TaskPermissions,
          FutureOr<TaskPermissions>
        >
    with $FutureModifier<TaskPermissions>, $FutureProvider<TaskPermissions> {
  /// チーム内での自分の操作権限
  TaskPermissionsProvider._({
    required TaskPermissionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'taskPermissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskPermissionsHash();

  @override
  String toString() {
    return r'taskPermissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TaskPermissions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TaskPermissions> create(Ref ref) {
    final argument = this.argument as int;
    return taskPermissions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskPermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskPermissionsHash() => r'22a91b8a39a3753c2803b8e5554f1afa0cfd995d';

/// チーム内での自分の操作権限

final class TaskPermissionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TaskPermissions>, int> {
  TaskPermissionsFamily._()
    : super(
        retry: null,
        name: r'taskPermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// チーム内での自分の操作権限

  TaskPermissionsProvider call(int teamId) =>
      TaskPermissionsProvider._(argument: teamId, from: this);

  @override
  String toString() => r'taskPermissionsProvider';
}

/// user_id → メンバー（アイコン表示用。退出済みも含む）

@ProviderFor(memberMap)
final memberMapProvider = MemberMapFamily._();

/// user_id → メンバー（アイコン表示用。退出済みも含む）

final class MemberMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, TeamMember>>,
          Map<String, TeamMember>,
          FutureOr<Map<String, TeamMember>>
        >
    with
        $FutureModifier<Map<String, TeamMember>>,
        $FutureProvider<Map<String, TeamMember>> {
  /// user_id → メンバー（アイコン表示用。退出済みも含む）
  MemberMapProvider._({
    required MemberMapFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberMapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberMapHash();

  @override
  String toString() {
    return r'memberMapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, TeamMember>> create(Ref ref) {
    final argument = this.argument as int;
    return memberMap(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberMapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberMapHash() => r'530dfdd016a635b5bd65ba02c19af7e52629c26d';

/// user_id → メンバー（アイコン表示用。退出済みも含む）

final class MemberMapFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, TeamMember>>, int> {
  MemberMapFamily._()
    : super(
        retry: null,
        name: r'memberMapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// user_id → メンバー（アイコン表示用。退出済みも含む）

  MemberMapProvider call(int teamId) =>
      MemberMapProvider._(argument: teamId, from: this);

  @override
  String toString() => r'memberMapProvider';
}

/// ゴミ箱（P1-07）

@ProviderFor(trashTasks)
final trashTasksProvider = TrashTasksFamily._();

/// ゴミ箱（P1-07）

final class TrashTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>
        >
    with $FutureModifier<List<Task>>, $FutureProvider<List<Task>> {
  /// ゴミ箱（P1-07）
  TrashTasksProvider._({
    required TrashTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'trashTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trashTasksHash();

  @override
  String toString() {
    return r'trashTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Task>> create(Ref ref) {
    final argument = this.argument as int;
    return trashTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrashTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trashTasksHash() => r'7fb71823fb5af51d53ba078f08c5f1358f3d8aee';

/// ゴミ箱（P1-07）

final class TrashTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Task>>, int> {
  TrashTasksFamily._()
    : super(
        retry: null,
        name: r'trashTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ゴミ箱（P1-07）

  TrashTasksProvider call(int teamId) =>
      TrashTasksProvider._(argument: teamId, from: this);

  @override
  String toString() => r'trashTasksProvider';
}

/// 完了ログ（P1-07）

@ProviderFor(completedTasks)
final completedTasksProvider = CompletedTasksFamily._();

/// 完了ログ（P1-07）

final class CompletedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>
        >
    with $FutureModifier<List<Task>>, $FutureProvider<List<Task>> {
  /// 完了ログ（P1-07）
  CompletedTasksProvider._({
    required CompletedTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'completedTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$completedTasksHash();

  @override
  String toString() {
    return r'completedTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Task>> create(Ref ref) {
    final argument = this.argument as int;
    return completedTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$completedTasksHash() => r'b9b6847a33558fb5938d7a0014f48eea0ca8e43d';

/// 完了ログ（P1-07）

final class CompletedTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Task>>, int> {
  CompletedTasksFamily._()
    : super(
        retry: null,
        name: r'completedTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 完了ログ（P1-07）

  CompletedTasksProvider call(int teamId) =>
      CompletedTasksProvider._(argument: teamId, from: this);

  @override
  String toString() => r'completedTasksProvider';
}

/// カレンダー用：チームの締切付きの付箋（P1-05）

@ProviderFor(teamDueTasks)
final teamDueTasksProvider = TeamDueTasksFamily._();

/// カレンダー用：チームの締切付きの付箋（P1-05）

final class TeamDueTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>
        >
    with $FutureModifier<List<Task>>, $FutureProvider<List<Task>> {
  /// カレンダー用：チームの締切付きの付箋（P1-05）
  TeamDueTasksProvider._({
    required TeamDueTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'teamDueTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamDueTasksHash();

  @override
  String toString() {
    return r'teamDueTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Task>> create(Ref ref) {
    final argument = this.argument as int;
    return teamDueTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamDueTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamDueTasksHash() => r'3599c16fdeebf55d3e7b123d2527a5967c57bc01';

/// カレンダー用：チームの締切付きの付箋（P1-05）

final class TeamDueTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Task>>, int> {
  TeamDueTasksFamily._()
    : super(
        retry: null,
        name: r'teamDueTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// カレンダー用：チームの締切付きの付箋（P1-05）

  TeamDueTasksProvider call(int teamId) =>
      TeamDueTasksProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamDueTasksProvider';
}

/// 付箋のステータス履歴

@ProviderFor(taskHistory)
final taskHistoryProvider = TaskHistoryFamily._();

/// 付箋のステータス履歴

final class TaskHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StatusHistory>>,
          List<StatusHistory>,
          FutureOr<List<StatusHistory>>
        >
    with
        $FutureModifier<List<StatusHistory>>,
        $FutureProvider<List<StatusHistory>> {
  /// 付箋のステータス履歴
  TaskHistoryProvider._({
    required TaskHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'taskHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskHistoryHash();

  @override
  String toString() {
    return r'taskHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StatusHistory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StatusHistory>> create(Ref ref) {
    final argument = this.argument as int;
    return taskHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskHistoryHash() => r'ce2042a800021c942ce71bb387b3f9c18bdd4c39';

/// 付箋のステータス履歴

final class TaskHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StatusHistory>>, int> {
  TaskHistoryFamily._()
    : super(
        retry: null,
        name: r'taskHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 付箋のステータス履歴

  TaskHistoryProvider call(int taskId) =>
      TaskHistoryProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskHistoryProvider';
}
