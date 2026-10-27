import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/alert_item.dart';

/// Vertical list of unresolved farm alerts.
///
/// All text is sourced from [AlertItem] fields — no hardcoded messages.
class AlertsSection extends StatelessWidget {
  const AlertsSection({
    super.key,
    required this.alerts,
    this.onSeeAll,
  });

  final List<AlertItem>  alerts;
  final VoidCallback?    onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (alerts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: EmptyState(
          icon:    Icons.check_circle_outline_rounded,
          message: l.dashboardAlertsEmpty,
        ),
      );
    }

    return Column(
      children: [
        ...alerts.take(3).map((a) => _AlertTile(alert: a)),
        if (alerts.length > 3 && onSeeAll != null) ...[
          const SizedBox(height: 4),
          _SeeAllButton(
            label:     l.dashboardSeeAllAlerts,
            onPressed: onSeeAll!,
          ),
        ],
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});
  final AlertItem alert;

  // ── Severity helpers ──────────────────────────────────────────────────────

  Color _bg(ColorScheme cs) => switch (alert.severity) {
    AlertSeverity.critical => cs.errorContainer,
    AlertSeverity.warning  => const Color(0xFFFFF3E0), // amber tint
    AlertSeverity.info     => cs.primaryContainer,
  };

  Color _fg(ColorScheme cs) => switch (alert.severity) {
    AlertSeverity.critical => cs.onErrorContainer,
    AlertSeverity.warning  => const Color(0xFFE65100),
    AlertSeverity.info     => cs.onPrimaryContainer,
  };

  IconData _icon() => switch (alert.severity) {
    AlertSeverity.critical => Icons.dangerous_outlined,
    AlertSeverity.warning  => Icons.warning_amber_outlined,
    AlertSeverity.info     => Icons.info_outlined,
  };

  String _severityLabel(AppLocalizations l) => switch (alert.severity) {
    AlertSeverity.critical => l.dashboardAlertSeverityCritical,
    AlertSeverity.warning  => l.dashboardAlertSeverityWarning,
    AlertSeverity.info     => l.dashboardAlertSeverityInfo,
  };

  @override
  Widget build(BuildContext context) {
    final l  = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bg = _bg(cs);
    final fg = _fg(cs);

    return Semantics(
      label: '${_severityLabel(l)} alert: ${alert.title}. ${alert.description}',
      child: Container(
        margin:  const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(), size: 20, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:      fg,
                          ),
                        ),
                      ),
                      // Field tag — shown only when the alert is field-specific.
                      if (alert.fieldName != null)
                        _FieldChip(name: alert.fieldName!, fg: fg, bg: bg),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.description,
                    style: tt.bodySmall?.copyWith(color: fg),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.name, required this.fg, required this.bg});
  final String name;
  final Color  fg;
  final Color  bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        fg.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.label, required this.onPressed});
  final String       label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child:     Text(label),
      ),
    );
  }
}
