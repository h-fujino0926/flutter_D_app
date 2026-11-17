// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 自分宛ての通知一覧と、そのリアルタイム受信（7.4）。
///
/// ログイン中はずっと `user:{uid}` チャンネルを購読し、
///   ・notifications の INSERT（自分宛て）→ 一覧に追加＋Windows のトースト通知
///   ・task_members の変更（自分の担当）→ マイタスクを取り直す
/// を行う。起動時は SELECT で未読を取り直す（起動していない間の通知の取りこぼし対策）。

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

/// 自分宛ての通知一覧と、そのリアルタイム受信（7.4）。
///
/// ログイン中はずっと `user:{uid}` チャンネルを購読し、
///   ・notifications の INSERT（自分宛て）→ 一覧に追加＋Windows のトースト通知
///   ・task_members の変更（自分の担当）→ マイタスクを取り直す
/// を行う。起動時は SELECT で未読を取り直す（起動していない間の通知の取りこぼし対策）。
final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<AppNotification>> {
  /// 自分宛ての通知一覧と、そのリアルタイム受信（7.4）。
  ///
  /// ログイン中はずっと `user:{uid}` チャンネルを購読し、
  ///   ・notifications の INSERT（自分宛て）→ 一覧に追加＋Windows のトースト通知
  ///   ・task_members の変更（自分の担当）→ マイタスクを取り直す
  /// を行う。起動時は SELECT で未読を取り直す（起動していない間の通知の取りこぼし対策）。
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();
}

String _$notificationsHash() => r'c8780c26c1b781362ac7478384f3380eb978d623';

/// 自分宛ての通知一覧と、そのリアルタイム受信（7.4）。
///
/// ログイン中はずっと `user:{uid}` チャンネルを購読し、
///   ・notifications の INSERT（自分宛て）→ 一覧に追加＋Windows のトースト通知
///   ・task_members の変更（自分の担当）→ マイタスクを取り直す
/// を行う。起動時は SELECT で未読を取り直す（起動していない間の通知の取りこぼし対策）。

abstract class _$Notifications extends $AsyncNotifier<List<AppNotification>> {
  FutureOr<List<AppNotification>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 未読の件数（ヘッダーのベルに表示）

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// 未読の件数（ヘッダーのベルに表示）

final class UnreadCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 未読の件数（ヘッダーのベルに表示）
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadCountHash() => r'9513e2e27d3e6aecf771612ecf61cf312842d042';
