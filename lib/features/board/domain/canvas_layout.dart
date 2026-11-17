import 'dart:ui';

import '../../../core/models/models.dart';

/// ボードのキャンバスの大きさ（論理px）。
/// 仮決定（E2）：列なしの自由配置。ウィンドウより大きい場合はスクロールする。
const double kCanvasWidth = 2400;
const double kCanvasHeight = 1600;

/// 付箋をキャンバスの中に収める
Offset clampToCanvas(Offset pos, TaskSize size) => Offset(
  pos.dx.clamp(0, kCanvasWidth - size.width),
  pos.dy.clamp(0, kCanvasHeight - size.height),
);

/// 新しい付箋を置く「空いている位置」を左上から探す。
Offset findFreePosition(Iterable<Task> tasks, {TaskSize size = TaskSize.m}) {
  const gapX = 230.0;
  const gapY = 200.0;
  for (var y = 24.0; y < kCanvasHeight - size.height; y += gapY) {
    for (var x = 24.0; x < kCanvasWidth - size.width; x += gapX) {
      final rect = Rect.fromLTWH(x, y, size.width, size.height);
      final overlaps = tasks.any(
        (t) => rect.overlaps(
          Rect.fromLTWH(t.posX, t.posY, t.size.width, t.size.height),
        ),
      );
      if (!overlaps) return Offset(x, y);
    }
  }
  return const Offset(24, 24);
}

/// 付箋ごとに少しだけ傾ける角度（±2°）。task_id から決めるので毎回同じ角度になる。
double tiltRadiansOf(int taskId) {
  final seed = (taskId * 2654435761) % 1000; // 簡易ハッシュ
  final degree = (seed / 1000) * 4 - 2; // -2〜+2
  return degree * 3.1415926535 / 180;
}
