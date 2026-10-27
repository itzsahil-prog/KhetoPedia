import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Variant-driven button used across all features.
enum AppButtonVariant { primary, secondary, outline, outlined, text, ghost, destructive }
enum AppButtonSize    { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant   = AppButtonVariant.primary,
    this.size      = AppButtonSize.medium,
    this.fullWidth = false,
    this.loading   = false,
    this.leading,
    this.trailing,
    this.icon,
    this.semanticLabel,
  });

  final String             label;
  final VoidCallback?      onPressed;
  final AppButtonVariant   variant;
  final AppButtonSize      size;
  final bool               fullWidth;
  final bool               loading;
  final Widget?            leading;
  final Widget?            trailing;
  final IconData?          icon;
  final String?            semanticLabel;

  // ── Sizing ──────────────────────────────────────────────────────────────
  double get _height {
    switch (size) {
      case AppButtonSize.small:  return 36;
      case AppButtonSize.large:  return 56;
      case AppButtonSize.medium: return 48;
    }
  }

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppButtonSize.small:  return const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.large:  return const EdgeInsets.symmetric(horizontal: 32);
      case AppButtonSize.medium: return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  double get _radius {
    switch (size) {
      case AppButtonSize.small:  return 8;
      case AppButtonSize.large:  return 14;
      case AppButtonSize.medium: return 12;
    }
  }

  // ── Colors ──────────────────────────────────────────────────────────────
  Color _bg(BuildContext ctx)   {
    final cs = Theme.of(ctx).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary     => cs.primary,
      AppButtonVariant.secondary   => cs.secondary,
      AppButtonVariant.destructive => cs.error,
      AppButtonVariant.outline ||
      AppButtonVariant.outlined ||
      AppButtonVariant.text ||
      AppButtonVariant.ghost       => Colors.transparent,
    };
  }

  Color _fg(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary     => cs.onPrimary,
      AppButtonVariant.secondary   => cs.onSecondary,
      AppButtonVariant.destructive => cs.onError,
      AppButtonVariant.outline ||
      AppButtonVariant.outlined ||
      AppButtonVariant.text ||
      AppButtonVariant.ghost       => cs.primary,
    };
  }

  BorderSide _border(BuildContext ctx) {
    if (variant == AppButtonVariant.outline || variant == AppButtonVariant.outlined) {
      return BorderSide(color: Theme.of(ctx).colorScheme.primary);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !loading;

    final Widget? leadingWidget = leading ?? (icon != null ? Icon(icon, size: 20) : null);

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingWidget != null) ...[leadingWidget, const SizedBox(width: 8)],
        Text(label),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    if (loading) {
      child = SizedBox.square(
        dimension: _height * 0.45,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_fg(context)),
        ),
      );
    }

    return Semantics(
      label:   semanticLabel ?? label,
      button:  true,
      enabled: !isDisabled,
      child: AnimatedOpacity(
        opacity:  isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width:  fullWidth ? double.infinity : null,
          height: _height,
          child: TextButton(
            onPressed: loading ? null : onPressed,
            style: TextButton.styleFrom(
              backgroundColor:        _bg(context),
              foregroundColor:        _fg(context),
              padding:                _padding,
              textStyle:              AppTextStyles.labelLarge(_fg(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
                side:         _border(context),
              ),
              minimumSize: Size(0, _height),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
