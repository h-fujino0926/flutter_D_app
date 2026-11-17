// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 管理モード ⇔ ミニモードの切り替え（機能29）。

@ProviderFor(WindowModeController)
final windowModeControllerProvider = WindowModeControllerProvider._();

/// 管理モード ⇔ ミニモードの切り替え（機能29）。
final class WindowModeControllerProvider
    extends $NotifierProvider<WindowModeController, WindowMode> {
  /// 管理モード ⇔ ミニモードの切り替え（機能29）。
  WindowModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowModeControllerHash();

  @$internal
  @override
  WindowModeController create() => WindowModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowMode>(value),
    );
  }
}

String _$windowModeControllerHash() =>
    r'28e3f5a6357e38a05560484e3ba47e7211397c7e';

/// 管理モード ⇔ ミニモードの切り替え（機能29）。

abstract class _$WindowModeController extends $Notifier<WindowMode> {
  WindowMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WindowMode, WindowMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WindowMode, WindowMode>,
              WindowMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
