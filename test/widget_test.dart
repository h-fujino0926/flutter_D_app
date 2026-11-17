import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_d_app/app/app.dart';
import 'package:flutter_d_app/features/board/presentation/board_page.dart';

void main() {
  testWidgets('env.json が無いときは設定エラー画面を表示する', (tester) async {
    await tester.pumpWidget(const MissingEnvApp());
    expect(find.textContaining('env.json'), findsWidgets);
  });

  testWidgets('ボード画面の骨組みが表示される', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: BoardPage()));
    expect(find.text('追加'), findsOneWidget);
    expect(find.text('完'), findsOneWidget);
    expect(find.text('ここにチームのタスクがまとめて表示'), findsOneWidget);
  });
}
