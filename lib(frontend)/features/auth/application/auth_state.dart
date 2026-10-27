import '../domain/domain.dart';

/// The four observable states the auth system can be in.
///
/// Sealed so the router and UI must handle every case exhaustively.
sealed class AuthState {
  const AuthState();
}

/// Initial state — checking stored tokens on startup.
/// The router shows a neutral splash while in this state.
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// A valid session exists.
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required this.user});
  final AuthUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthStateAuthenticated && other.user == user);

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'AuthStateAuthenticated(user: $user)';
}

/// No session — the user must sign in.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// A recoverable failure occurred during an auth operation.
/// The session state itself has not changed — the UI should show the error.
final class AuthStateError extends AuthState {
  const AuthStateError({
    required this.failure,
    /// The state the app was in before the error, so the router can
    /// decide whether to stay on the auth flow or on the main flow.
    required this.previousState,
  });

  final AuthFailure failure;
  final AuthState   previousState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthStateError &&
          other.failure       == failure &&
          other.previousState == previousState);

  @override
  int get hashCode => Object.hash(failure, previousState);

  @override
  String toString() =>
      'AuthStateError(failure: $failure, previousState: $previousState)';
}
