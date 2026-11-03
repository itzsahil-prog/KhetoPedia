import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/field_summary.dart';

/// Vertical list of recently-accessed field cards.
///
/// All displayed values come from [FieldSummary] — none are invented.
class RecentFieldsSection extends StatelessWidget {
  const RecentFieldsSection({
    super.key,
    required this.fields,
    this.onFieldTap,
    this.onSeeAll,
  });

  final List<FieldSummary>        fields;
  final ValueChanged<FieldSummary>? onFieldTap;
  final VoidCallback?               onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (fields.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: EmptyState(
          icon:    Icons.landscape_outlined,
          message: l.dashboardFieldsEmpty,
        ),
      );
    }

    return Column(
      children: [
        ...fields.take(3).map(
          (f) => _FieldCard(
            field:  f,
            onTap:  onFieldTap != null ? () => onFieldTap!(f) : null,
          ),
        ),
        if (fields.length > 3 && onSeeAll != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSeeAll,
              child:     Text(l.dashboardSeeAllFields),
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.field, this.onTap});
  final FieldSummary field;
  final VoidCallback? onTap;

  // ── Status helpers ────────────────────────────────────────────────────────

  String _statusLabel(AppLocalizations l) => switch (field.status) {
    'healthy'  => l.dashboardStatusHealthy,
    'at_risk'  => l.dashboardStatusAtRisk,
    'critical' => l.dashboardStatusCritical,
    _          => field.status ?? '',
  };

  Color _statusBg(ColorScheme cs) => switch (field.status) {
    'healthy'  => cs.primaryContainer,
    'at_risk'  => const Color(0xFFFFF3E0),
    'critical' => cs.errorContainer,
    _          => cs.surfaceContainerHighest,
  };

  Color _statusFg(ColorScheme cs) => switch (field.status) {
    'healthy'  => cs.onPrimaryContainer,
    'at_risk'  => const Color(0xFFE65100),
    'critical' => cs.onErrorContainer,
    _          => cs.onSurfaceVariant,
  };

  // ── Health score indicator ────────────────────────────────────────────────

  Color _scoreColor(ColorScheme cs) {
    final s = field.healthScore;
    if (s == null) return cs.onSurfaceVariant;
    if (s >= 70)   return cs.primary;
    if (s >= 40)   return const Color(0xFFF57F17);
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context);
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;
    final score = field.healthScore;

    final semanticDesc =
        '${field.cropName} in ${field.name}. '
        '${field.areaHectares.toStringAsFixed(1)} ${l.dashboardFieldAreaHectares}. '
        '${score != null ? '${l.dashboardFieldHealthScore}: $score. ' : ''}'
        '${_statusLabel(l)}';

    return Semantics(
      label:  semanticDesc,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        cs.surface,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: cs.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: crop name + status badge ────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.cropName,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          field.name,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (field.status != null)
                    _StatusBadge(
                      label: _statusLabel(l),
                      bg:    _statusBg(cs),
                      fg:    _statusFg(cs),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Row 2: area + health score ──────────────────────────────
              Row(
                children: [
                  _MetaChip(
                    icon:  Icons.landscape_outlined,
                    label: '${field.areaHectares.toStringAsFixed(1)} ${l.dashboardFieldAreaHectares}',
                  ),
                  const SizedBox(width: 12),
                  if (score != null)
                    _MetaChip(
                      icon:       Icons.monitor_heart_outlined,
                      label:      '${l.dashboardFieldHealthScore}: $score',
                      iconColor:  _scoreColor(cs),
                    )
                  else
                    _MetaChip(
                      icon:      Icons.qr_code_scanner_rounded,
                      label:     l.dashboardFieldNeverScanned,
                      iconColor: cs.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.bg,
    required this.fg,
  });
  final String label;
  final Color  bg;
  final Color  fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });
  final IconData icon;
  final String   label;
  final Color?   iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
