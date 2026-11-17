import 'package:fake_async/fake_async.dart';
import 'package:flutter_d_app/core/utils/throttle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('100ms以内の連続呼び出しは、最初と最後の2回だけ実行される', () {
    fakeAsync((async) {
      final throttler = Throttler(const Duration(milliseconds: 100));
      final sent = <int>[];

      // 10ms ごとに 0〜9 を送ろうとする（ドラッグ中を想定）
      for (var i = 0; i < 10; i++) {
        throttler.run(() => sent.add(i));
        async.elapse(const Duration(milliseconds: 10));
      }
      async.elapse(const Duration(milliseconds: 200));

      // 最初の 0 はすぐ、最後の 9 は間隔が明けてから送られる
      expect(sent, [0, 9]);
    });
  });

  test('cancel すると保留中の処理は実行されない', () {
    fakeAsync((async) {
      final throttler = Throttler(const Duration(milliseconds: 100));
      final sent = <int>[];

      throttler.run(() => sent.add(1));
      throttler.run(() => sent.add(2));
      throttler.cancel();
      async.elapse(const Duration(milliseconds: 200));

      expect(sent, [1]);
    });
  });
}
