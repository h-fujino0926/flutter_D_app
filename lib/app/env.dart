/// ビルド時に `--dart-define-from-file=env.json` で渡される設定値。
///
/// クライアントに置いてよいのは Project URL と publishable（anon）キーだけ。
/// service_role キーは絶対にここへ入れないこと。
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// env.json が渡されていない場合は false。
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
