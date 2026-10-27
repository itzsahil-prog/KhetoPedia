import 'package:flutter/material.dart';
import '../../core/localization/localization.dart';
import 'app_button.dart';

/// Full-page error state with optional retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String?        message;
  final VoidCallback?  onRetry;
  final IconData       icon;

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Semantics(
      label: message ?? l.errorGeneric,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: cs.error, semanticLabel: 'Error'),
              const SizedBox(height: 16),
              Text(
                message ?? l.errorGeneric,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                AppButton(
                  label:     l.retry,
                  onPressed: onRetry,
                  variant:   AppButtonVariant.outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
