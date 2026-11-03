import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/domain.dart';

// ── Result type (reuses the same record pattern as auth) ─────────────────────

typedef DashboardResult<T> = ({String? error, T? value});

DashboardResult<T> _ok<T>(T v)       => (error: null,    value: v);
DashboardResult<T> _err<T>(String m) => (error: m,       value: null);

// ── Abstract interface ────────────────────────────────────────────────────────

abstract interface class DashboardRepository {
  /// Fetch the aggregated dashboard summary for the authenticated user.
  Future<DashboardResult<DashboardSummary>> getSummary();
}

// ── HTTP implementation ───────────────────────────────────────────────────────

final class HttpDashboardRepository implements DashboardRepository {
  const HttpDashboardRepository(this._dio);
  final Dio _dio;

  @override
  Future<DashboardResult<DashboardSummary>> getSummary() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        ApiConstants.dashboardSummary,
      );
      final data = resp.data;
      if (data == null) return _err('Empty response from server.');
      return _ok(DashboardSummary.fromJson(data));
    } on DioException catch (e) {
      return _err(_mapDio(e));
    } catch (e) {
      return _err('Unexpected error: $e');
    }
  }

  static String _mapDio(DioException e) {
    final net = DioClient.mapException(e);
    return switch (net) {
      ConnectionException() => 'No internet connection.',
      TimeoutException()    => 'Request timed out.',
      ServerException(:final statusCode, :final message) when statusCode == 401
                            => 'Session expired. Please sign in again.',
      ServerException(:final message) => message,
      _                     => net.message,
    };
  }
}
