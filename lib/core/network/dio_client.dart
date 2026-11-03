import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'auth_interceptor.dart';
import 'network_exception.dart';

/// Factory that builds a configured [Dio] instance.
///
/// The [AuthInterceptor] is attached lazily via [attachAuthInterceptor]
/// so the network client can be constructed before the auth state is ready.
class DioClient {
  DioClient._();

  static Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl:        ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
      ),
    );

    // Logging in debug builds only.
    assert(() {
      dio.interceptors.add(LogInterceptor(
        requestBody:  true,
        responseBody: true,
        logPrint:     (o) => print(o), // ignore: avoid_print
      ));
      return true;
    }());

    return dio;
  }

  /// Attach auth interceptor after the Dio instance is built.
  static void attachAuthInterceptor(
    Dio dio,
    AuthInterceptorDelegate delegate,
  ) {
    // Remove any existing AuthInterceptor to avoid duplicates.
    dio.interceptors.removeWhere((i) => i is AuthInterceptor);
    dio.interceptors.add(AuthInterceptor(dio, delegate));
  }

  /// Converts [DioException] to a typed [NetworkException].
  static NetworkException mapException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const ConnectionException();

      case DioExceptionType.badResponse:
        final resp = e.response;
        if (resp == null) return const ParseException();

        final body    = resp.data;
        final message = _extractMessage(body);
        final code    = _extractCode(body);

        return ServerException(
          statusCode: resp.statusCode ?? 0,
          message:    message,
          code:       code,
        );

      case DioExceptionType.cancel:
        return const ConnectionException('Request cancelled.');

      case DioExceptionType.badCertificate:
        return const ConnectionException('SSL certificate error.');

      case DioExceptionType.unknown:
      default:
        return UnknownNetworkException(e.message ?? 'Unknown network error.');
    }
  }

  static String _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return (body['detail'] ?? body['message'] ?? body['error'] ?? 'Server error.')
          .toString();
    }
    return 'Server error.';
  }

  static String? _extractCode(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['code']?.toString();
    }
    return null;
  }
}
