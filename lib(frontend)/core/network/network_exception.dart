/// Typed network-layer errors surfaced to the repository layer.
///
/// Keeps Dio out of the domain and application layers entirely.
sealed class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server returned a 4xx/5xx with a parseable body.
final class ServerException extends NetworkException {
  const ServerException({
    required this.statusCode,
    required String message,
    this.code,
  }) : super(message);
  final int statusCode;
  /// Machine-readable error code returned by the API, e.g. `TOKEN_EXPIRED`.
  final String? code;
}

/// Could not reach the server (no internet, DNS failure, timeout).
final class ConnectionException extends NetworkException {
  const ConnectionException([super.message = 'No internet connection.']);
}

/// Request timed out.
final class TimeoutException extends NetworkException {
  const TimeoutException([super.message = 'Request timed out.']);
}

/// Response body could not be parsed.
final class ParseException extends NetworkException {
  const ParseException([super.message = 'Failed to parse server response.']);
}

/// Unknown network error.
final class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException([super.message = 'Unknown network error.']);
}
