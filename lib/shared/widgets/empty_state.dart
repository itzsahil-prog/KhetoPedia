import 'package:flutter/material.dart';
import '../../core/localization/localization.dart';
import 'app_button.dart';

/// Full-page empty state with icon, title, message, and optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon         = Icons.inbox_outlined,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData       icon;
  final String?        title;
  final String?        message;
  final String?        actionLabel;
  final VoidCallback?  onAction;

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Semantics(
      label: title ?? l.emptyGeneric,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              const SizedBox(height: 8),
              Text(
                message ?? l.emptyGeneric,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 24),
                AppButton(
                  label:     actionLabel!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
