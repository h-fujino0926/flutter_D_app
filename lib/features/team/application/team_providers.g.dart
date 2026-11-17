// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 参加中のチーム一覧（機能20）

@ProviderFor(myTeams)
final myTeamsProvider = MyTeamsProvider._();

/// 参加中のチーム一覧（機能20）

final class MyTeamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Team>>,
          List<Team>,
          FutureOr<List<Team>>
        >
    with $FutureModifier<List<Team>>, $FutureProvider<List<Team>> {
  /// 参加中のチーム一覧（機能20）
  MyTeamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTeamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTeamsHash();

  @$internal
  @override
  $FutureProviderElement<List<Team>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Team>> create(Ref ref) {
    return myTeams(ref);
  }
}

String _$myTeamsHash() => r'b74755ddfeaed64eb4e17f4202f729e99560a3ea';

/// チームのボード一覧

@ProviderFor(teamBoards)
final teamBoardsProvider = TeamBoardsFamily._();

/// チームのボード一覧

final class TeamBoardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Board>>,
          List<Board>,
          FutureOr<List<Board>>
        >
    with $FutureModifier<List<Board>>, $FutureProvider<List<Board>> {
  /// チームのボード一覧
  TeamBoardsProvider._({
    required TeamBoardsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'teamBoardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamBoardsHash();

  @override
  String toString() {
    return r'teamBoardsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Board>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Board>> create(Ref ref) {
    final argument = this.argument as int;
    return teamBoards(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamBoardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamBoardsHash() => r'b4942c872a9f45305596a05fcd8483a63cd33b7a';

/// チームのボード一覧

final class TeamBoardsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Board>>, int> {
  TeamBoardsFamily._()
    : super(
        retry: null,
        name: r'teamBoardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// チームのボード一覧

  TeamBoardsProvider call(int teamId) =>
      TeamBoardsProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamBoardsProvider';
}

/// チームのメンバー一覧（退出済みを含む）

@ProviderFor(teamMembers)
final teamMembersProvider = TeamMembersFamily._();

/// チームのメンバー一覧（退出済みを含む）

final class TeamMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamMember>>,
          List<TeamMember>,
          FutureOr<List<TeamMember>>
        >
    with $FutureModifier<List<TeamMember>>, $FutureProvider<List<TeamMember>> {
  /// チームのメンバー一覧（退出済みを含む）
  TeamMembersProvider._({
    required TeamMembersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'teamMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamMembersHash();

  @override
  String toString() {
    return r'teamMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TeamMember>> create(Ref ref) {
    final argument = this.argument as int;
    return teamMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamMembersHash() => r'15fde6cd79b2edbd16c4032ef74da28227c7c755';

/// チームのメンバー一覧（退出済みを含む）

final class TeamMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TeamMember>>, int> {
  TeamMembersFamily._()
    : super(
        retry: null,
        name: r'teamMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// チームのメンバー一覧（退出済みを含む）

  TeamMembersProvider call(int teamId) =>
      TeamMembersProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamMembersProvider';
}

/// 自分のプロフィール

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

/// 自分のプロフィール

final class MyProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  /// 自分のプロフィール
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'05a8e7bbe46840da07f9e208c35d87539b108914';

/// 自分のユーザー設定（user_settings）

@ProviderFor(userSettings)
final userSettingsProvider = UserSettingsProvider._();

/// 自分のユーザー設定（user_settings）

final class UserSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserSettings>,
          UserSettings,
          FutureOr<UserSettings>
        >
    with $FutureModifier<UserSettings>, $FutureProvider<UserSettings> {
  /// 自分のユーザー設定（user_settings）
  UserSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsHash();

  @$internal
  @override
  $FutureProviderElement<UserSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserSettings> create(Ref ref) {
    return userSettings(ref);
  }
}

String _$userSettingsHash() => r'fbc129910b3577a2a7b22fc977b8fffa0dcb1926';

/// 現在のチーム・ボードの選択。変更すると user_settings にも保存する（機能18）。

@ProviderFor(CurrentSelection)
final currentSelectionProvider = CurrentSelectionProvider._();

/// 現在のチーム・ボードの選択。変更すると user_settings にも保存する（機能18）。
final class CurrentSelectionProvider
    extends $NotifierProvider<CurrentSelection, Selection?> {
  /// 現在のチーム・ボードの選択。変更すると user_settings にも保存する（機能18）。
  CurrentSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSelectionHash();

  @$internal
  @override
  CurrentSelection create() => CurrentSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Selection? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Selection?>(value),
    );
  }
}

String _$currentSelectionHash() => r'4de20a64b57e46547b27a3af5f671b8be1852883';

/// 現在のチーム・ボードの選択。変更すると user_settings にも保存する（機能18）。

abstract class _$CurrentSelection extends $Notifier<Selection?> {
  Selection? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Selection?, Selection?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Selection?, Selection?>,
              Selection?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。

@ProviderFor(myMembership)
final myMembershipProvider = MyMembershipFamily._();

/// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。

final class MyMembershipProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamMember?>,
          TeamMember?,
          FutureOr<TeamMember?>
        >
    with $FutureModifier<TeamMember?>, $FutureProvider<TeamMember?> {
  /// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。
  MyMembershipProvider._({
    required MyMembershipFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'myMembershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myMembershipHash();

  @override
  String toString() {
    return r'myMembershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TeamMember?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeamMember?> create(Ref ref) {
    final argument = this.argument as int;
    return myMembership(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyMembershipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myMembershipHash() => r'1e0be9f17e4cecb6b8d3694b790abc0ddf2ff77d';

/// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。

final class MyMembershipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TeamMember?>, int> {
  MyMembershipFamily._()
    : super(
        retry: null,
        name: r'myMembershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 現在のチームでの自分のメンバー情報（ロール判定用）。未所属なら null。

  MyMembershipProvider call(int teamId) =>
      MyMembershipProvider._(argument: teamId, from: this);

  @override
  String toString() => r'myMembershipProvider';
}
