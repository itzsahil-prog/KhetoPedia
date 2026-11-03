import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

/// User profile screen showing account information and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is NetworkException ? err.toString() : l.errorGeneric,
          onRetry: () => ref.read(profileProvider.notifier).refresh(),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.read(profileProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile information
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: l.profileName,
                      value: profile.name,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: l.profileEmail,
                      value: profile.email,
                    ),
                    if (profile.phone != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l.profilePhone,
                        value: profile.phone!,
                      ),
                    ],
                    if (profile.location != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: l.profileLocation,
                        value: profile.location!,
                      ),
                    ],
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.language_outlined,
                      label: l.profilePreferredLocale,
                      value: profile.preferredLocale == 'hi' ? 'हिन्दी' : 'English',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Farm statistics
              if (profile.totalFields != null || profile.totalArea != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dashboardSectionStats,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (profile.totalFields != null)
                            Expanded(
                              child: _StatTile(
                                icon: Icons.landscape_outlined,
                                label: l.tabFields,
                                value: profile.totalFields.toString(),
                              ),
                            ),
                          if (profile.totalArea != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.straighten_outlined,
                                label: l.fieldsArea,
                                value: '${profile.totalArea!.toStringAsFixed(1)} ${l.dashboardFieldAreaHectares}',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Actions
              AppButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: profile),
                    ),
                  );
                },
                label: l.profileEdit,
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
                label: l.profileChangePassword,
                icon: Icons.lock_outline,
                variant: AppButtonVariant.outlined,
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.authLogout),
                      content: Text(l.confirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l.authLogout),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await authNotifier.logout();
                    if (context.mounted) {
                      context.goNamed(AppRoutes.login);
                    }
                  }
                },
                label: l.authLogout,
                icon: Icons.logout,
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}


