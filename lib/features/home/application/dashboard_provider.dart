import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/auth_providers.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // Shares the single authenticated Dio instance from the auth layer.
  return HttpDashboardRepository(ref.read(dioProvider));
});

// ── AsyncNotifier ─────────────────────────────────────────────────────────────

/// Manages the lifecycle of [DashboardSummary] fetches.
///
/// Exposes:
///   • `state` — `AsyncValue<DashboardSummary>` (loading / data / error)
///   • `refresh()` — force a fresh network call; re-enters loading state
///
/// The notifier is auto-disposed when the dashboard tab is unmounted, so
/// navigating back to Home always shows a current snapshot.
class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() => _fetch();

  /// Public refresh — called on pull-to-refresh or retry button.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<DashboardSummary> _fetch() async {
    final repo   = ref.read(dashboardRepositoryProvider);
    final result = await repo.getSummary();

    if (result.error != null) {
      // Throw so AsyncValue.guard / build() wraps it as AsyncError.
      throw DashboardException(result.error!);
    }
    return result.value!;
  }
}

/// Typed exception so the UI can show a specific error message.
final class DashboardException implements Exception {
  const DashboardException(this.message);
  final String message;
  @override
  String toString() => message;
}

// ── Provider instance ─────────────────────────────────────────────────────────

/// Auto-disposed so re-entering the home tab always re-fetches.
final dashboardProvider =
    AsyncNotifierProvider.autoDispose<DashboardNotifier, DashboardSummary>(
  DashboardNotifier.new,
);
