import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/ai_screen.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/verify_otp_screen.dart';
import '../../features/fields/fields_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/soil/soil_screen.dart';
import '../../shared/layout/app_shell.dart';

// ── Route name constants ──────────────────────────────────────────────────────

abstract final class AppRoutes {
  // ── Auth (unauthenticated flow) ───────────────────────────────────────────
  static const login          = 'login';
  static const signup         = 'signup';
  static const forgotPassword = 'forgot-password';
  static const verifyOtp      = 'verify-otp';

  // ── Main shell (authenticated flow) ──────────────────────────────────────
  static const home           = 'home';
  static const scan           = 'scan';
  static const fields         = 'fields';
  static const soil           = 'soil';
  static const ai             = 'ai';
}

// ── Route path constants (for redirect comparisons) ──────────────────────────

abstract final class AppPaths {
  static const login          = '/login';
  static const signup         = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyOtp      = '/verify-otp';
  static const home           = '/home';

  /// All paths that belong to the unauthenticated flow.
  static const Set<String> authPaths = {
    login, signup, forgotPassword, verifyOtp,
  };
}

// ── Navigator keys ────────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// ── Router provider ───────────────────────────────────────────────────────────

/// [GoRouter] exposed as a Riverpod provider so the redirect guard can read
/// [authStateProvider] synchronously via [Ref].
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes so GoRouter re-evaluates the redirect.
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    navigatorKey:        _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation:     AppPaths.home,
    refreshListenable:   authListenable,

    // ── Redirect guard ───────────────────────────────────────────────────────
    redirect: (context, state) {
      final authState   = ref.read(authStateProvider);
      final currentPath = state.uri.path;
      final onAuthRoute = AppPaths.authPaths.contains(currentPath);

      return switch (authState) {
        // Still loading stored tokens — show inline splash, don't redirect.
        AuthStateLoading() => null,

        // Authenticated — push off auth screens to home.
        AuthStateAuthenticated() =>
            onAuthRoute ? AppPaths.home : null,

        // Unauthenticated or session-expired error — push to login unless
        // already on an auth screen.
        AuthStateUnauthenticated() ||
        AuthStateError(
          previousState: AuthStateUnauthenticated(),
        ) =>
            onAuthRoute ? null : AppPaths.login,

        // Transient error while already authenticated — stay put.
        AuthStateError() => null,
      };
    },

    routes: [
      // ── Auth routes (outside the main shell) ────────────────────────────
      GoRoute(
        name:    AppRoutes.login,
        path:    AppPaths.login,
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        name:    AppRoutes.signup,
        path:    AppPaths.signup,
        builder: (ctx, state) => const SignupScreen(),
      ),
      GoRoute(
        name:    AppRoutes.forgotPassword,
        path:    AppPaths.forgotPassword,
        builder: (ctx, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name:    AppRoutes.verifyOtp,
        path:    AppPaths.verifyOtp,
        builder: (ctx, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final mode  = state.uri.queryParameters['mode']  ?? 'reset';
          return VerifyOtpScreen(email: email, mode: mode);
        },
      ),

      // ── Authenticated shell with 5 branches ─────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              name:    AppRoutes.home,
              path:    AppPaths.home,
              builder: (ctx, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name:    AppRoutes.scan,
              path:    '/scan',
              builder: (ctx, state) => const ScanScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name:    AppRoutes.fields,
              path:    '/fields',
              builder: (ctx, state) => const FieldsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name:    AppRoutes.soil,
              path:    '/soil',
              builder: (ctx, state) => const SoilScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              name:    AppRoutes.ai,
              path:    '/ai',
              builder: (ctx, state) => const AIScreen(),
            ),
          ]),
        ],
      ),
    ],

    // ── Error page ───────────────────────────────────────────────────────────
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(ctx).textTheme.bodyLarge,
        ),
      ),
    ),
  );
});

// ── Auth state → Listenable bridge ───────────────────────────────────────────

/// Notifies GoRouter whenever [authStateProvider] emits a new value,
/// causing the redirect guard to be re-evaluated.
///
/// This is the standard pattern for wiring Riverpod state to GoRouter's
/// [refreshListenable] without coupling the router to a ChangeNotifier.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}
