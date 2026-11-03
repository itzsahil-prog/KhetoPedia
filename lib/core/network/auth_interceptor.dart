import 'package:dio/dio.dart';

import 'api_constants.dart';

/// Header injected on every authenticated request.
const _kAuthHeader = 'Authorization';

/// Key used to mark a request as "already retried after token refresh".
/// Prevents infinite retry loops.
const _kRetryKey = 'retry_after_refresh';

/// Callbacks the interceptor needs but cannot own itself
/// (to avoid circular dependencies between the network layer and auth state).
abstract interface class AuthInterceptorDelegate {
  /// Returns the current access token, or null if unauthenticated.
  Future<String?> getAccessToken();

  /// Attempts a silent token refresh.
  ///
  /// Returns `true` if refresh succeeded and tokens were persisted.
  /// Returns `false` (or throws) if refresh failed (e.g. refresh token expired).
  Future<bool> refreshTokens();

  /// Called when silent refresh fails — the session must be ended.
  Future<void> onRefreshFailed();
}

/// Dio interceptor that:
///   1. Attaches `Authorization: Bearer <accessToken>` to every request
///      (unless the request already carries one).
///   2. On 401, silently refreshes tokens once and retries the request.
///   3. Calls [delegate.onRefreshFailed] if refresh itself returns 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._delegate);

  final Dio                   _dio;
  final AuthInterceptorDelegate _delegate;

  // ── onRequest ────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for auth endpoints that don't need it.
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _delegate.getAccessToken();
    if (token != null) {
      options.headers[_kAuthHeader] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── onError ──────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final options  = err.requestOptions;

    // Only handle 401 once per request (avoid infinite loops).
    if (response?.statusCode != 401 ||
        options.extra[_kRetryKey] == true ||
        _isPublicEndpoint(options.path)) {
      return handler.next(err);
    }

    // Mark so we don't retry again.
    options.extra[_kRetryKey] = true;

    final refreshed = await _delegate.refreshTokens();
    if (!refreshed) {
      await _delegate.onRefreshFailed();
      return handler.next(err);
    }

    // Inject the new access token and retry.
    final newToken = await _delegate.getAccessToken();
    if (newToken != null) {
      options.headers[_kAuthHeader] = 'Bearer $newToken';
    }

    try {
      final retried = await _dio.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isPublicEndpoint(String path) => const {
    ApiConstants.authLogin,
    ApiConstants.authSignup,
    ApiConstants.authRefresh,
    ApiConstants.authForgotPassword,
    ApiConstants.authVerifyOtp,
    ApiConstants.authResetPassword,
  }.any((ep) => path.endsWith(ep));
}
