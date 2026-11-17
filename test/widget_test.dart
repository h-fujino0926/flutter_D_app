import 'package:flutter/material.dart';
import 'package:flutter_d_app/app/app.dart';
import 'package:flutter_d_app/core/ui/code_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('env.json が無いときは設定エラー画面を表示する', (tester) async {
    await tester.pumpWidget(const MissingEnvApp());
    expect(find.textContaining('env.json'), findsWidgets);
  });

  group('CodeInput（P0-03 パスコード入力）', () {
    Future<List<String?>> pump(WidgetTester tester) async {
      final values = <String?>[];
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CodeInput(onChanged: values.add))),
      );
      return values;
    }

    testWidgets('貼り付けると6枠に分配され、6桁そろうとコードが返る', (tester) async {
      final values = await pump(tester);
      await tester.enterText(find.byType(TextField).first, 'abc234');
      await tester.pump();
      expect(values.last, 'ABC234'); // 小文字は大文字にそろえる
    });

    testWidgets('1文字ずつ入力すると次の枠へ進み、5桁ではまだ null', (tester) async {
      final values = await pump(tester);
      final fields = find.byType(TextField);
      for (var i = 0; i < 5; i++) {
        await tester.enterText(fields.at(i), 'A');
        await tester.pump();
      }
      expect(values.last, isNull);
      await tester.enterText(fields.at(5), '9');
      await tester.pump();
      expect(values.last, 'AAAAA9');
    });
  });
}
