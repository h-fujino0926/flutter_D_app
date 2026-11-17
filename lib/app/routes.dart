/// 画面のパス。画面IDは設計書（27_画面設計書）に合わせてコメントに書く。
class AppRoutes {
  const AppRoutes._();

  // ---- ログイン前 ----
  /// P0-01 ログイン
  static const login = '/login';

  /// P0-02 新規登録
  static const signup = '/signup';

  /// ※ 新規登録の確認コード入力（本番で Confirm email が ON のとき）
  static const verifySignup = '/verify';

  /// P0-04 パスワード再設定
  static const resetPassword = '/reset-password';

  // ---- ログイン後 ----
  /// 起動直後の振り分け（前回のボード／チーム作成／スマホ版）
  static const home = '/home';

  /// チーム未所属のときの画面（チーム作成 or 招待で参加）
  static const setup = '/setup';

  /// P1-01 メイン（ボード）。?task=ID で付箋詳細を開く
  static const board = '/board';

  /// P0-03 パスコード入力（招待で参加）。?token=xxx
  static const join = '/join';

  /// P1-08 チーム管理
  static const team = '/team';

  /// P1-09 設定
  static const settings = '/settings';

  /// P1-06 通知一覧
  static const notifications = '/notifications';

  /// P1-07 ゴミ箱・完了ログ
  static const trash = '/trash';

  /// P2-01 常駐ミニウィンドウ
  static const mini = '/mini';

  /// スマホ版（閲覧専用）
  static const mobile = '/mobile';

  /// 付箋を開く（チーム・ボードを切り替えてから詳細を開く）
  static String openTask(int taskId) => '/open-task/$taskId';

  static String boardWithTask(int taskId) => '$board?task=$taskId';

  static String joinWithToken(String token) =>
      Uri(path: join, queryParameters: {'token': token}).toString();
}
