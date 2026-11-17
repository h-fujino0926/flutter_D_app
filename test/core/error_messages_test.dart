import 'package:flutter_d_app/core/errors/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('RPC の独自エラーコードを日本語に変換する', () {
    const error = PostgrestException(message: 'INVITE_EXPIRED', code: 'P0001');
    expect(toJapaneseMessage(error), '招待コードの有効期限（3日間）が切れています');
  });

  test('RLS 違反（42501）は権限エラーとして表示する', () {
    const error = PostgrestException(message: 'new row violates', code: '42501');
    expect(toJapaneseMessage(error), 'この操作を行う権限がありません');
  });

  test('ログイン失敗を日本語に変換する', () {
    const error = AuthException('Invalid login credentials');
    expect(toJapaneseMessage(error), 'メールアドレスまたはパスワードが正しくありません');
  });

  test('未知の例外でも落ちずにメッセージを返す', () {
    expect(toJapaneseMessage(Exception('x')), '予期しないエラーが発生しました');
  });
}
