import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import 'application/auth_notifier.dart';
import 'application/auth_state.dart';
import 'data/auth_repository.dart';
import 'data/token_storage.dart';

// ── 1. Secure storage ─────────────────────────────────────────────────────────

/// Raw [FlutterSecureStorage] instance — one per app lifetime.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

/// Token storage abstraction backed by the platform keychain / keystore.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage(ref.read(flutterSecureStorageProvider));
});

// ── 2. Dio ────────────────────────────────────────────────────────────────────

/// The single [Dio] instance used across the app.
///
/// The [AuthInterceptor] is attached here via a ProviderRef listener so it
/// can obtain a fresh [AuthNotifier] reference without creating a circular
/// dependency at construction time.
final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.build();

  // Lazily wire the auth interceptor once authNotifierProvider is available.
  // Using ref.listen avoids reading the notifier before it is built.
  final delegate = _DelegateAdapter(ref);
  DioClient.attachAuthInterceptor(dio, delegate);

  return dio;
});

/// Adapter that bridges the [AuthInterceptorDelegate] interface to the
/// Riverpod provider tree without capturing a stale notifier reference.
final class _DelegateAdapter implements AuthInterceptorDelegate {
  const _DelegateAdapter(this._ref);
  final Ref _ref;

  AuthNotifier get _notifier => _ref.read(authNotifierProvider.notifier);

  @override
  Future<String?> getAccessToken() => _notifier.getAccessToken();

  @override
  Future<bool> refreshTokens() => _notifier.refreshTokens();

  @override
  Future<void> onRefreshFailed() => _notifier.onRefreshFailed();
}

// ── 3. Auth repository ────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return HttpAuthRepository(
    dio:     ref.read(dioProvider),
    storage: ref.read(tokenStorageProvider),
  );
});

// ── 4. Auth notifier + state ──────────────────────────────────────────────────

/// Primary auth notifier — drives [AuthState] for the whole app.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Convenience read-only selector for the current [AuthState].
///
/// Feature code that only needs to *read* state (not call methods) should
/// watch this rather than the full notifier to minimise rebuilds.
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});
