/// Typed failures for the auth feature.
///
/// Sealed so every caller must handle all cases exhaustively.
sealed class AuthFailure {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ── Credential / input failures ──────────────────────────────────────────────

/// Email or password did not match any account.
final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials()
      : super('Incorrect email or password. Please try again.');
}

/// An account with this email already exists.
final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse()
      : super('An account with this email already exists.');
}

/// The provided OTP is wrong or expired.
final class InvalidOtp extends AuthFailure {
  const InvalidOtp() : super('The verification code is invalid or has expired.');
}

/// A reset or signup link has expired.
final class LinkExpired extends AuthFailure {
  const LinkExpired() : super('This link has expired. Please request a new one.');
}

// ── Session / token failures ──────────────────────────────────────────────────

/// The refresh token is expired — user must sign in again.
final class SessionExpired extends AuthFailure {
  const SessionExpired()
      : super('Your session has expired. Please sign in again.');
}

/// No authenticated session was found.
final class Unauthenticated extends AuthFailure {
  const Unauthenticated() : super('You are not signed in.');
}

// ── Network / server failures ─────────────────────────────────────────────────

/// The server returned an unexpected error.
final class ServerFailure extends AuthFailure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

/// The device has no internet connection.
final class NoConnection extends AuthFailure {
  const NoConnection()
      : super('No internet connection. Please check your network.');
}

/// An unclassified failure — message comes from the server or exception.
final class UnknownFailure extends AuthFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
