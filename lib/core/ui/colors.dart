import 'package:flutter/material.dart';

/// "#RRGGBB" → Color（不正な値なら fallback）
Color colorFromHex(String hex, {Color fallback = const Color(0xFFFFF59D)}) {
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return fallback;
  return Color(0xFF000000 | parsed);
}

/// Color → "#RRGGBB"
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// 付箋の色プリセット（6色）
const stickyColorPresets = <String>[
  '#FFF59D', // 黄
  '#FFCC80', // オレンジ
  '#F8BBD0', // ピンク
  '#B3E5FC', // 水色
  '#C8E6C9', // 緑
  '#E1BEE7', // 紫
];

/// ユーザーのアイコン色プリセット
const iconColorPresets = <String>[
  '#F4A261',
  '#E76F51',
  '#2A9D8F',
  '#264653',
  '#E9C46A',
  '#8E7DBE',
  '#457B9D',
  '#D62828',
];
