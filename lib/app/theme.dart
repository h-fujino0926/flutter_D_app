import 'package:flutter/material.dart';

/// アプリ全体のテーマ。
class AppTheme {
  const AppTheme._();

  /// 付箋っぽい黄色をベースカラーにする。
  static const Color seedColor = Color(0xFFF2C94C);

  /// Windows で日本語がきれいに出るフォント（無ければ OS の既定フォント）。
  static const List<String> _fontFallback = ['Yu Gothic UI', 'Meiryo'];

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamilyFallback: _fontFallback,
      scaffoldBackgroundColor: const Color(0xFFFAF7F0),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
