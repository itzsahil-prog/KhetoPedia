import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'metric_badge_model.dart';
export 'metric_badge_model.dart';

class MetricBadgeWidget extends StatefulWidget {
  const MetricBadgeWidget({
    super.key,
    Color? color,
    this.icon,
    String? label,
    String? value,
  })  : color = color ?? Colors.blue,
        label = label ?? 'Moisture',
        value = value ?? '64%';

  final Color color;
  final Widget? icon;
  final String label;
  final String value;

  @override
  State<MetricBadgeWidget> createState() => _MetricBadgeWidgetState();
}

class _MetricBadgeWidgetState extends State<MetricBadgeWidget> {
  late MetricBadgeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MetricBadgeModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            Text(
              widget.label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            Text(
              widget.value,
              style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ].divide(const SizedBox(width: 4)),
        ),
      ),
    );
  }
}
