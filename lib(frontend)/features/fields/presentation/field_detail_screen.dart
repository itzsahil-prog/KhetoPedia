import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/fields_provider.dart';
import 'add_edit_field_screen.dart';

/// Field detail screen showing all field information.
class FieldDetailScreen extends ConsumerWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fieldAsync = ref.watch(fieldProvider(fieldId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.fieldsDetail),
        actions: [
          fieldAsync.when(
            data: (field) => PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 12),
                      Text(l.fieldsEdit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(l.fieldsDelete, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditFieldScreen(field: field),
                    ),
                  );
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.fieldsDelete),
                      content: Text(l.fieldsDeleteConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(l.fieldsDelete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(fieldsNotifierProvider.notifier).deleteField(fieldId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.fieldsDeleted)),
                      );
                      Navigator.pop(context);
                    }
                  }
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: fieldAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: l.errorGeneric,
          onRetry: () => ref.invalidate(fieldProvider(fieldId)),
        ),
        data: (field) => RefreshIndicator(
          onRefresh: () => ref.refresh(fieldProvider(fieldId).future),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header card
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.landscape,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      field.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.grass_outlined,
                      label: l.fieldsCrop,
                      value: field.crop,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.straighten_outlined,
                      label: l.fieldsArea,
                      value: '${field.area.toStringAsFixed(2)} ${l.dashboardFieldAreaHectares}',
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.favorite_outline,
                      label: l.fieldsHealthScore,
                      value: '${field.healthScore}%',
                      valueColor: _getHealthColor(field.healthScore),
                    ),
                    if (field.waterStatus != null) ...[
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.water_drop_outlined,
                        label: 'Water Status',
                        value: field.waterStatus!.toUpperCase(),
                      ),
                    ],
                    if (field.soilStatus != null) ...[
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.science_outlined,
                        label: 'Soil Status',
                        value: field.soilStatus!.toUpperCase(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
