import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_messages.dart';
import '../../application/board_controller.dart';
import '../../domain/canvas_layout.dart';
import 'sticky_note.dart';

/// 付箋を自由に配置するキャンバス（列なし。仮決定 E2）。
/// ウィンドウより大きいので縦横にスクロールできる。
class BoardCanvas extends ConsumerStatefulWidget {
  const BoardCanvas({super.key, required this.teamId, required this.boardId});

  final int teamId;
  final int boardId;

  @override
  ConsumerState<BoardCanvas> createState() => _BoardCanvasState();
}

class _BoardCanvasState extends ConsumerState<BoardCanvas> {
  final _horizontal = ScrollController();
  final _vertical = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = boardTasksProvider(widget.boardId);
    // 付箋の「一覧（ID の並び）」だけを監視し、個々の付箋の変化では再描画しない
    // （List は == で中身を比べないので、文字列にして比較する）
    final idsKey = ref.watch(
      provider.select((s) => ((s.value?.keys.toList() ?? <int>[])..sort()).join(',')),
    );
    final ids = idsKey.isEmpty ? const <int>[] : idsKey.split(',').map(int.parse).toList();
    final async = ref.watch(provider.select((s) => (s.isLoading && !s.hasValue, s.error)));

    if (async.$1) return const Center(child: CircularProgressIndicator());
    if (async.$2 != null && ids.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(toJapaneseMessage(async.$2!)),
            TextButton(onPressed: () => ref.invalidate(provider), child: const Text('再読み込み')),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _vertical,
      thumbVisibility: true,
      child: Scrollbar(
        controller: _horizontal,
        thumbVisibility: true,
        notificationPredicate: (n) => n.depth == 1,
        child: SingleChildScrollView(
          controller: _vertical,
          child: SingleChildScrollView(
            controller: _horizontal,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: kCanvasWidth,
              height: kCanvasHeight,
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
                  if (ids.isEmpty)
                    const Positioned(
                      left: 32,
                      top: 32,
                      child: Text('まだ付箋がありません。右上の「追加」から作成できます'),
                    ),
                  for (final id in ids)
                    StickyNote(
                      key: ValueKey(id),
                      boardId: widget.boardId,
                      teamId: widget.teamId,
                      taskId: id,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 背景の点線グリッド（コルクボード風）
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black12;
    for (var x = 0.0; x < size.width; x += 40) {
      for (var y = 0.0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
