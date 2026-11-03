import 'package:flutter/material.dart';

/// Accessible card with consistent radius, border, and elevation.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding    = const EdgeInsets.all(16),
    this.onTap,
    this.semanticLabel,
    this.color,
    this.borderColor,
  });

  final Widget                child;
  final EdgeInsetsGeometry    padding;
  final VoidCallback?         onTap;
  final String?               semanticLabel;
  final Color?                color;
  final Color?                borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    Widget card = Container(
      decoration: BoxDecoration(
        color:        color ?? cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? cs.outline,
          width: 1,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      card = Semantics(
        label:  semanticLabel,
        button: true,
        child:  InkWell(
          onTap:       onTap,
          borderRadius: BorderRadius.circular(12),
          child:        card,
        ),
      );
    } else if (semanticLabel != null) {
      card = Semantics(label: semanticLabel, child: card);
    }

    return card;
  }
}
