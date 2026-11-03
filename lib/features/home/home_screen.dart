import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/localization.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/auth_providers.dart';
import '../../shared/widgets/widgets.dart';
import 'application/dashboard_provider.dart';
import 'domain/dashboard_summary.dart';
import 'presentation/widgets/alerts_section.dart';
import 'presentation/widgets/dashboard_header.dart';
import 'presentation/widgets/quick_stats_row.dart';
import 'presentation/widgets/recent_fields_section.dart';

/// Authenticated farmer dashboard.
///
/// State rules:
///   • While [dashboardProvider] is loading  → [LoadingView].
///   • On network / server error             → [ErrorView] with retry.
///   • On success with empty payload         → [EmptyState].
///   • On success with data                  → full dashboard layout.
///
/// Pull-to-refresh triggers [DashboardNotifier.refresh].
/// No value on screen is hardcoded — every number, label, or status
/// originates from the API response.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l         = AppLocalizations.of(context);
    final authState = ref.watch(authNotifierProvider);

    // Extract authenticated user — guard against unexpected state.
    final user = switch (authState) {
      AuthStateAuthenticated(:final user) => user,
      _                                   => null,
    };

    if (user == null) {
      // Should never reach here (router guard prevents it), but handle safely.
      return Scaffold(
        body: ErrorView(
          message: l.errorGeneric,
          onRetry: () => context.goNamed(AppRoutes.login),
        ),
      );
    }

    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest
          .withAlpha(40),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardProvider.notifier).refresh(),
          child: dashAsync.when(
            loading: () => const LoadingView(),
            error:   (err, _) => _ErrorBody(
              message: err is DashboardException ? err.message : l.errorGeneric,
              onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
            data: (summary) => _DashboardBody(user: user, summary: summary),
          ),
        ),
      ),
    );
  }
}

// ── Error body (scrollable so pull-to-refresh still works) ───────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String       message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: ErrorView(message: message, onRetry: onRetry),
        ),
      ],
    );
  }
}

// ── Main content body ─────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.user, required this.summary});

  final dynamic         user;    // AuthUser
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l  = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Fully empty payload — no stats, fields, or alerts.
    if (summary.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: DashboardHeader(user: user)),
          SliverFillRemaining(
            child: EmptyState(
              icon:    Icons.agriculture_outlined,
              title:   l.dashboardTitle,
              message: l.dashboardFieldsEmpty,
              actionLabel: l.tabFields,
              onAction: () => context.goNamed(AppRoutes.fields),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Header ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: DashboardHeader(user: user),
        ),

        // ── Quick stats ──────────────────────────────────────────────────────
        if (summary.hasStats) ...[
          _SectionHeader(title: l.dashboardSectionStats),
          SliverToBoxAdapter(
            child: QuickStatsRow(stats: summary.stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],

        // ── Active alerts ─────────────────────────────────────────────────────
        _SectionHeader(title: l.dashboardSectionAlerts),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: AlertsSection(
              alerts:   summary.activeAlerts,
              onSeeAll: summary.activeAlerts.length > 3
                  ? () => context.goNamed(AppRoutes.fields)
                  : null,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── Recent fields ─────────────────────────────────────────────────────
        _SectionHeader(title: l.dashboardSectionRecentFields),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverToBoxAdapter(
            child: RecentFieldsSection(
              fields:    summary.recentFields,
              onSeeAll:  () => context.goNamed(AppRoutes.fields),
              onFieldTap: (_) => context.goNamed(AppRoutes.fields),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Text(
          title,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color:      cs.onSurface,
          ),
        ),
      ),
    );
  }
}
