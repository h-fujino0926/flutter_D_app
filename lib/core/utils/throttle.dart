import 'dart:async';

/// 一定間隔に1回までしか処理を実行しないための間引き（throttle）。
///
/// 付箋のドラッグ中に、位置を Realtime の broadcast で送る処理に使う
/// （無料プランのメッセージ数対策で 100ms に1回まで）。
///
/// - 最初の呼び出しはすぐ実行する（leading）。
/// - 間隔中に来た呼び出しは最後の1つだけを覚えておき、間隔が明けたら実行する
///   （trailing）。これでドラッグを止めた位置が必ず相手に届く。
class Throttler {
  Throttler(this.interval);

  final Duration interval;

  Timer? _timer;
  void Function()? _pending;

  void run(void Function() action) {
    if (_timer == null) {
      action();
      _startTimer();
    } else {
      _pending = action;
    }
  }

  void _startTimer() {
    _timer = Timer(interval, () {
      _timer = null;
      final pending = _pending;
      _pending = null;
      if (pending != null) {
        // 保留していた最後の呼び出しを実行し、また間隔を空ける。
        pending();
        _startTimer();
      }
    });
  }

  /// 保留中の処理を捨てて止める（画面を離れるときなどに呼ぶ）。
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }
}
