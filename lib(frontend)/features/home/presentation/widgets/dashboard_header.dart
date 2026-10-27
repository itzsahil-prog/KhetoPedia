import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../features/auth/domain/auth_user.dart';

/// Greeting header at the top of the dashboard.
///
/// The greeting word (good morning / afternoon / evening) is derived from
/// the device clock — no hardcoded time strings.
/// The user's name comes exclusively from [AuthUser] — never hardcoded.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user});

  final AuthUser user;

  String _greeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.dashboardGreetingMorning;
    if (hour < 17) return l.dashboardGreetingAfternoon;
    return l.dashboardGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l  = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Use first name only for brevity (derived from the API value).
    final firstName = user.name.split(' ').first;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting(l)}, $firstName',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:      cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Avatar — uses network image when available, falls back to initials.
          _UserAvatar(user: user),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});
  final AuthUser user;

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = user.avatarUrl;

    return Semantics(
      label: 'Profile picture of ${user.name}',
      child: CircleAvatar(
        radius: 22,
        backgroundColor: cs.primaryContainer,
        foregroundImage: (url != null && url.isNotEmpty)
            ? NetworkImage(url)
            : null,
        onForegroundImageError: (_, __) {}, // fall through to initials
        child: Text(
          _initials,
          style: TextStyle(
            color:      cs.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize:   15,
          ),
        ),
      ),
    );
  }
}
