import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/auth_interceptor.dart';
import '../auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/token_storage.dart';
import '../domain/domain.dart';
import 'auth_state.dart';

/// Drives the global authentication state.
///
/// Also implements [AuthInterceptorDelegate] so the Dio interceptor can
/// silently refresh tokens and notify this notifier of session expiry —
/// all without creating a circular provider dependency.
class AuthNotifier extends Notifier<AuthState>
    implements AuthInterceptorDelegate {
  // The repository and storage are injected via [build] to allow
  // Riverpod to re-create the notifier if those providers change.
  late AuthRepository  _repository;
  late TokenStorage    _storage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage    = ref.read(tokenStorageProvider);
    // Kick off startup check asynchronously — state starts as loading.
    _initializeSession();
    return const AuthStateLoading();
  }

  // ── Startup ───────────────────────────────────────────────────────────────

  /// Checks for persisted tokens on app start.
  /// If a valid access token exists, fetches the user profile.
  /// If only a refresh token exists, attempts a silent refresh first.
  Future<void> _initializeSession() async {
    final tokens = await _storage.load();

    if (tokens == null) {
      state = const AuthStateUnauthenticated();
      return;
    }

    // If the access token is known to be expired, try refresh first.
    if (tokens.isAccessTokenExpired) {
      final refreshed = await refreshTokens();
      if (!refreshed) {
        state = const AuthStateUnauthenticated();
        return;
      }
    }

    // Fetch user profile to confirm the session is alive.
    final result = await _repository.getMe();
    if (result.value != null) {
      state = AuthStateAuthenticated(user: result.value!);
    } else {
      // getMe failed (e.g. token truly expired) — clear and ask to sign in.
      await _storage.clear();
      state = const AuthStateUnauthenticated();
    }
  }

  // ── Public auth actions ───────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    state = const AuthStateLoading();
    final result = await _repository.login(
      LoginRequest(email: email, password: password),
    );

    if (result.value != null) {
      state = AuthStateAuthenticated(user: result.value!.user);
    } else {
      state = AuthStateError(
        failure:       result.failure!,
        previousState: const AuthStateUnauthenticated(),
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    String preferredLocale = 'en',
  }) async {
    state = const AuthStateLoading();
    final result = await _repository.signup(
      SignupRequest(
        name:            name,
        email:           email,
        password:        password,
        phone:           phone,
        preferredLocale: preferredLocale,
      ),
    );

    if (result.value != null) {
      state = AuthStateAuthenticated(user: result.value!.user);
    } else {
      state = AuthStateError(
        failure:       result.failure!,
        previousState: const AuthStateUnauthenticated(),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthStateUnauthenticated();
  }

  Future<void> forgotPassword(String email) async {
    final prev = state;
    final result = await _repository.forgotPassword(email);
    if (result.failure != null) {
      state = AuthStateError(failure: result.failure!, previousState: prev);
    }
    // On success, state is unchanged — the UI navigates to the OTP screen.
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    final prev = state;
    final result = await _repository.verifyOtp(email: email, otp: otp);
    if (result.failure != null) {
      state = AuthStateError(failure: result.failure!, previousState: prev);
      return false;
    }
    return true;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final prev = state;
    final result = await _repository.resetPassword(
      email:       email,
      otp:         otp,
      newPassword: newPassword,
    );
    if (result.failure != null) {
      state = AuthStateError(failure: result.failure!, previousState: prev);
      return false;
    }
    return true;
  }

  /// Clear a transient error and restore the previous session state.
  void clearError() {
    if (state case AuthStateError(:final previousState)) {
      state = previousState;
    }
  }

  // ── AuthInterceptorDelegate impl ──────────────────────────────────────────

  @override
  Future<String?> getAccessToken() async {
    final tokens = await _storage.load();
    return tokens?.accessToken;
  }

  @override
  Future<bool> refreshTokens() async {
    final tokens = await _storage.load();
    if (tokens == null) return false;

    final result = await _repository.refreshTokens(tokens.refreshToken);
    return result.value != null;
  }

  @override
  Future<void> onRefreshFailed() async {
    await _storage.clear();
    state = AuthStateError(
      failure:       const SessionExpired(),
      previousState: const AuthStateUnauthenticated(),
    );
  }
}

// ── Provider declarations (referenced by data providers below) ───────────────
// These are declared here and re-exported via the providers barrel so that
// auth_notifier.dart is a single import point for auth application logic.

// Forward declarations — implementations are in auth_providers.dart to
// avoid circular imports. We use late-bound ProviderListenable refs instead.

// NOTE: The actual provider instances live in
// lib/features/auth/auth_providers.dart which is created in task 10.
// Here we just export the notifier class and state.
