import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/domain.dart';
import 'token_storage.dart';

// ── Request / Response DTOs ───────────────────────────────────────────────────

/// Everything the login endpoint accepts.
final class LoginRequest {
  const LoginRequest({required this.email, required this.password});
  final String email;
  final String password;
  Map<String, dynamic> toJson() => {
    'email':    email,
    'password': password,
  };
}

/// Everything the signup endpoint accepts.
final class SignupRequest {
  const SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.preferredLocale = 'en',
  });
  final String  name;
  final String  email;
  final String  password;
  final String? phone;
  final String  preferredLocale;
  Map<String, dynamic> toJson() => {
    'name':             name,
    'email':            email,
    'password':         password,
    if (phone != null) 'phone': phone,
    'preferred_locale': preferredLocale,
  };
}

/// Result of a successful login or signup.
final class AuthResponse {
  const AuthResponse({required this.tokens, required this.user});
  final AuthTokens tokens;
  final AuthUser   user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // The server may nest tokens at root or inside a 'tokens' key.
    final tokenMap = (json['tokens'] as Map<String, dynamic>?) ?? json;
    return AuthResponse(
      tokens: AuthTokens.fromJson(tokenMap),
      user:   AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// ── Abstract interface ────────────────────────────────────────────────────────

/// Contract that all auth repository implementations must satisfy.
///
/// Returns [AuthFailure] on the left for all anticipated failures, and the
/// success value on the right. Uses a simple record `(AuthFailure?, T?)` to
/// avoid a full Either type without adding a dependency.
///
/// Convention: exactly one of the two tuple members is non-null.
typedef AuthResult<T> = ({AuthFailure? failure, T? value});

AuthResult<T> _ok<T>(T v)  => (failure: null, value: v);
AuthResult<T> _err<T>(AuthFailure f) => (failure: f, value: null);

abstract interface class AuthRepository {
  Future<AuthResult<AuthResponse>> login(LoginRequest request);
  Future<AuthResult<AuthResponse>> signup(SignupRequest request);
  Future<AuthResult<void>>         logout();
  Future<AuthResult<AuthTokens>>   refreshTokens(String refreshToken);
  Future<AuthResult<void>>         forgotPassword(String email);
  Future<AuthResult<void>>         verifyOtp({
    required String email,
    required String otp,
  });
  Future<AuthResult<void>>         resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<AuthResult<AuthUser>>     getMe();
}

// ── HTTP implementation ───────────────────────────────────────────────────────

/// Concrete repository that talks to the Khetopedia REST API via Dio.
///
/// All [DioException]s are caught here, mapped to [NetworkException] via
/// [DioClient.mapException], and then mapped again to the correct [AuthFailure]
/// subtype — no Dio types leak past this class.
final class HttpAuthRepository implements AuthRepository {
  const HttpAuthRepository({
    required Dio          dio,
    required TokenStorage storage,
  })  : _dio     = dio,
        _storage = storage;

  final Dio           _dio;
  final TokenStorage  _storage;

  // ── login ─────────────────────────────────────────────────────────────────

  @override
  Future<AuthResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: request.toJson(),
      );
      final auth = AuthResponse.fromJson(resp.data!);
      await _storage.save(auth.tokens);
      return _ok(auth);
    } on DioException catch (e) {
      return _err(_mapNetworkToAuth(DioClient.mapException(e)));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── signup ────────────────────────────────────────────────────────────────

  @override
  Future<AuthResult<AuthResponse>> signup(SignupRequest request) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authSignup,
        data: request.toJson(),
      );
      final auth = AuthResponse.fromJson(resp.data!);
      await _storage.save(auth.tokens);
      return _ok(auth);
    } on DioException catch (e) {
      return _err(_mapNetworkToAuth(DioClient.mapException(e)));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── logout ────────────────────────────────────────────────────────────────

  @override
  Future<AuthResult<void>> logout() async {
    // Best-effort server call; always clear local tokens.
    try {
      await _dio.post<void>(ApiConstants.authLogout);
    } on DioException {
      // Ignore — we clear storage regardless.
    } finally {
      await _storage.clear();
    }
    return _ok(null);
  }

  // ── refreshTokens ─────────────────────────────────────────────────────────

  @override
  Future<AuthResult<AuthTokens>> refreshTokens(String refreshToken) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      final tokens = AuthTokens.fromJson(resp.data!);
      await _storage.save(tokens);
      return _ok(tokens);
    } on DioException catch (e) {
      final net = DioClient.mapException(e);
      if (net is ServerException && net.statusCode == 401) {
        await _storage.clear();
        return _err(const SessionExpired());
      }
      return _err(_mapNetworkToAuth(net));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── forgotPassword ────────────────────────────────────────────────────────

  @override
  Future<AuthResult<void>> forgotPassword(String email) async {
    try {
      await _dio.post<void>(
        ApiConstants.authForgotPassword,
        data: {'email': email},
      );
      return _ok(null);
    } on DioException catch (e) {
      return _err(_mapNetworkToAuth(DioClient.mapException(e)));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── verifyOtp ─────────────────────────────────────────────────────────────

  @override
  Future<AuthResult<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.authVerifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return _ok(null);
    } on DioException catch (e) {
      final net = DioClient.mapException(e);
      if (net is ServerException) {
        if (net.statusCode == 400 ||
            net.code == 'INVALID_OTP' ||
            net.code == 'OTP_EXPIRED') {
          return _err(const InvalidOtp());
        }
      }
      return _err(_mapNetworkToAuth(net));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── resetPassword ─────────────────────────────────────────────────────────

  @override
  Future<AuthResult<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.authResetPassword,
        data: {
          'email':        email,
          'otp':          otp,
          'new_password': newPassword,
        },
      );
      return _ok(null);
    } on DioException catch (e) {
      final net = DioClient.mapException(e);
      if (net is ServerException && net.statusCode == 400) {
        return _err(const InvalidOtp());
      }
      return _err(_mapNetworkToAuth(net));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── getMe ─────────────────────────────────────────────────────────────────

  @override
  Future<AuthResult<AuthUser>> getMe() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(ApiConstants.authMe);
      return _ok(AuthUser.fromJson(resp.data!));
    } on DioException catch (e) {
      final net = DioClient.mapException(e);
      if (net is ServerException && net.statusCode == 401) {
        return _err(const Unauthenticated());
      }
      return _err(_mapNetworkToAuth(net));
    } catch (_) {
      return _err(const UnknownFailure());
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  /// Converts a [NetworkException] to the most specific [AuthFailure].
  static AuthFailure _mapNetworkToAuth(NetworkException e) {
    return switch (e) {
      ConnectionException() => const NoConnection(),
      TimeoutException()    => const NoConnection(),
      ServerException(statusCode: 401) => const InvalidCredentials(),
      ServerException(statusCode: 409, code: 'EMAIL_EXISTS') =>
          const EmailAlreadyInUse(),
      ServerException(statusCode: 409) => const EmailAlreadyInUse(),
      ServerException(statusCode: 410) => const LinkExpired(),
      ServerException(:final message)  => ServerFailure(message),
      ParseException()  => const ServerFailure(),
      UnknownNetworkException(:final message) => UnknownFailure(message),
    };
  }
}
