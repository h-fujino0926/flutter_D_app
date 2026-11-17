import 'package:flutter/foundation.dart';

/// 実行中のプラットフォーム判定。
///
/// window_manager / tray_manager / local_notifier は Windows でしか動かないため、
/// これらを呼ぶ前に必ず [isDesktop] で判定すること（スマホで呼ぶとエラーになる）。
class PlatformInfo {
  const PlatformInfo._();

  /// 主対象の Windows デスクトップかどうか。
  static bool get isDesktop =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// 閲覧専用アプリとして動かすスマホ（Android / iOS）かどうか。
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
