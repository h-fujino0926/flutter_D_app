import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// DB（RPC）が `raise exception 'コード'` で返すエラーコードと、
/// 画面に出す日本語メッセージの対応表。
///
/// コードを増やしたときは supabase/migrations の RPC とここの両方を更新すること。
const Map<String, String> rpcErrorMessages = {
  'NOT_AUTHENTICATED': 'ログインしてください',
  'FORBIDDEN': 'この操作を行う権限がありません',
  'NOT_FOUND': '対象のデータが見つかりません',
  'INVALID_INPUT': '入力内容に誤りがあります',
  // 招待
  'INVITE_NOT_FOUND': 'この招待は無効です',
  'INVITE_EXPIRED': '招待コードの有効期限（3日間）が切れています',
  'INVITE_LIMIT': 'この招待は使用上限に達しています',
  'WRONG_PASSCODE': 'パスコードが正しくありません',
  // チーム
  'OWNER_CANNOT_LEAVE': 'チームの作成者は退出できません',
  'OWNER_ROLE_LOCKED': 'チームの作成者のロールは変更できません',
  'LAST_LEADER': '最後のリーダーのため、この操作はできません',
  // タスク
  'TASK_ALREADY_DONE': 'このタスクはすでに完了しています',
  'TASK_NOT_DONE': 'このタスクは完了していません',
  'TASK_DELETED': 'このタスクは削除されています',
  'UNDO_EXPIRED': '元に戻せる時間を過ぎました',
  'COMMENT_REQUIRED': '差し戻しにはメッセージが必要です',
};

/// 例外を、SnackBar などに表示する日本語メッセージに変換する。
String toJapaneseMessage(Object error) {
  if (error is PostgrestException) {
    // RPC の独自コードは message にそのまま入ってくる。
    final custom = rpcErrorMessages[error.message];
    if (custom != null) return custom;
    // PostgreSQL 標準のエラーコード
    switch (error.code) {
      case '42501': // insufficient_privilege（RLS違反など）
        return 'この操作を行う権限がありません';
      case '23505': // unique_violation
        return 'すでに登録されています';
      case '23514': // check_violation
        return '入力内容に誤りがあります（開始日時が締切より後になっていないか確認してください）';
      case '23503': // foreign_key_violation
        return '関連するデータが見つかりません';
    }
    return 'サーバーでエラーが発生しました';
  }
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'メールアドレスまたはパスワードが正しくありません';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'このメールアドレスはすでに登録されています';
    }
    if (message.contains('email not confirmed')) {
      return 'メールアドレスの確認が完了していません';
    }
    if (message.contains('token has expired') ||
        message.contains('invalid') && message.contains('otp')) {
      return '確認コードが正しくないか、有効期限が切れています';
    }
    if (message.contains('password')) {
      return 'パスワードは8文字以上で入力してください';
    }
    return '認証でエラーが発生しました';
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is RealtimeSubscribeException) {
    return '通信できませんでした。ネットワーク接続を確認してください';
  }
  return '予期しないエラーが発生しました';
}
