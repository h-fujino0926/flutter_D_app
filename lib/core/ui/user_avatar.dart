import 'package:flutter/material.dart';

import '../models/models.dart';
import 'colors.dart';

/// ユーザーアイコン（頭文字＋ユーザーごとの色の丸）。画像は使わない（DB容量対策）。
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.profile,
    this.size = 24,
    this.inactive = false,
  });

  final Profile? profile;
  final double size;

  /// 退出済みメンバーはグレーで表示する
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName ?? '?';
    final color = inactive
        ? Colors.grey
        : colorFromHex(profile?.iconColor ?? '#9E9E9E');
    return Tooltip(
      message: inactive ? '$name（退出済み）' : name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: size > 20 ? 1.5 : 1),
        ),
        child: Text(
          name.isEmpty ? '?' : name.characters.first,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
