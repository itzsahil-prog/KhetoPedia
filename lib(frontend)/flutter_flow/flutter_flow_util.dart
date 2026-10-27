import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flutter_flow_theme.dart';

export 'package:go_router/go_router.dart' show GoRouterHelper;

// ─── valueOrDefault ────────────────────────────────────────────────────────
T valueOrDefault<T>(T? value, T defaultValue) =>
    value ?? defaultValue;

// ─── safeSetState ──────────────────────────────────────────────────────────
void safeSetState(VoidCallback fn) => fn();

// ─── Divider utility used by .divide() extension ──────────────────────────
extension WidgetListExtension on List<Widget> {
  List<Widget> divide(Widget divider) {
    if (isEmpty) return this;
    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(divider);
    }
    return result;
  }
}

// ─── Base model ────────────────────────────────────────────────────────────
abstract class FlutterFlowModel<W extends Widget> {
  void initState(BuildContext context) {}
  void dispose() {}
  void maybeDispose() => dispose();
  void onUpdate() {}
}

// ─── createModel helper ────────────────────────────────────────────────────
T createModel<T extends FlutterFlowModel>(
    BuildContext context, T Function() creator) {
  final model = creator();
  model.initState(context);
  return model;
}

// ─── wrapWithModel helper ──────────────────────────────────────────────────
W wrapWithModel<W extends Widget>({
  required FlutterFlowModel model,
  required VoidCallback updateCallback,
  required W child,
}) {
  return child;
}

// ─── GoRouter context extensions ──────────────────────────────────────────
extension GoRouterContextExtensions on BuildContext {
  void goNamed(String name, {Map<String, String> pathParameters = const {}}) {
    GoRouter.of(this).goNamed(name);
  }

  void pushNamed(String name, {Map<String, String> pathParameters = const {}}) {
    GoRouter.of(this).pushNamed(name);
  }
}
