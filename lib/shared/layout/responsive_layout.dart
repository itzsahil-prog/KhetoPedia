import 'package:flutter/material.dart';

/// Breakpoints following Material 3 adaptive layout guidance.
///
/// compact  < 600 dp  → phone portrait
/// medium   600–839   → phone landscape / small tablet
/// expanded ≥ 840     → tablet / desktop
enum ScreenClass { compact, medium, expanded }

extension on double {
  ScreenClass get screenClass {
    if (this < 600)  return ScreenClass.compact;
    if (this < 840)  return ScreenClass.medium;
    return ScreenClass.expanded;
  }
}

/// Provides [ScreenClass] and raw [Size] from the nearest [MediaQuery].
///
/// Usage:
/// ```dart
/// final layout = ResponsiveLayout.of(context);
/// if (layout.isCompact) { ... }
/// ```
class ResponsiveLayout {
  const ResponsiveLayout._({
    required this.screenClass,
    required this.size,
    required this.textScaleFactor,
  });

  final ScreenClass screenClass;
  final Size        size;
  final double      textScaleFactor;

  bool get isCompact  => screenClass == ScreenClass.compact;
  bool get isMedium   => screenClass == ScreenClass.medium;
  bool get isExpanded => screenClass == ScreenClass.expanded;

  static ResponsiveLayout of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ResponsiveLayout._(
      screenClass:     mq.size.width.screenClass,
      size:            mq.size,
      textScaleFactor: mq.textScaler.scale(1),
    );
  }
}

/// Switches between compact and expanded subtrees.
///
/// ```dart
/// AdaptiveBuilder(
///   compact:  PhoneLayout(),
///   expanded: TabletLayout(),
/// )
/// ```
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder  compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    return switch (layout.screenClass) {
      ScreenClass.expanded => (expanded ?? medium ?? compact)(context),
      ScreenClass.medium   => (medium   ?? compact)(context),
      ScreenClass.compact  => compact(context),
    };
  }
}
