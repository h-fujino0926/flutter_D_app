import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Supabase クライアント（アプリ全体で1つ）。
@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) => Supabase.instance.client;

/// ログイン状態の変化（ログイン・ログアウト・トークン更新など）。
@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) =>
    ref.watch(supabaseProvider).auth.onAuthStateChange;

/// ログイン中のユーザーID（未ログインなら null）。
@Riverpod(keepAlive: true)
String? currentUserId(Ref ref) {
  // ログイン状態が変わるたびに計算し直す
  ref.watch(authStateProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
}
