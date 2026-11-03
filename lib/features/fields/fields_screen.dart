import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization.dart';
import '../../shared/widgets/widgets.dart';
import 'fields/application/fields_provider.dart';
import 'fields/presentation/add_edit_field_screen.dart';
import 'fields/presentation/field_detail_screen.dart';

/// Fields management screen showing list of all fields.
class FieldsScreen extends ConsumerWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fieldsAsync = ref.watch(fieldsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.fieldsTitle),
      ),
      body: fieldsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: l.errorGeneric,
          onRetry: () => ref.invalidate(fieldsListProvider),
        ),
        data: (fields) {
          if (fields.isEmpty) {
            return EmptyState(
              icon: Icons.landscape_outlined,
              title: l.fieldsTitle,
              message: l.fieldsEmpty,
              actionLabel: l.fieldsAdd,
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditFieldScreen()),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(fieldsListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: fields.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final field = fields[index];
                return AppCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FieldDetailScreen(fieldId: field.id),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.landscape, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              field.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${field.area.toStringAsFixed(1)} ${l.dashboardFieldAreaHectares}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.grass_outlined,
                            label: field.crop,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.favorite_outline,
                            label: '${field.healthScore}%',
                            color: _getHealthColor(field.healthScore),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditFieldScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l.fieldsAdd),
      ),
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withAlpha(26) ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
