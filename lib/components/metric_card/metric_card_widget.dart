import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'metric_card_model.dart';
export 'metric_card_model.dart';

class MetricCardWidget extends StatefulWidget {
  const MetricCardWidget({
    super.key,
    Color? color,
    this.icon,
    String? label,
    Color? subcolor,
    String? subtext,
    String? value,
  })  : color = color ?? const Color(0xFF5D4037),
        label = label ?? 'pH Level',
        subcolor = subcolor ?? const Color(0x00000000),
        subtext = subtext ?? 'Slightly Acidic',
        value = value ?? '6.8';

  final Color color;
  final Widget? icon;
  final String label;
  final Color subcolor;
  final String subtext;
  final String value;

  @override
  State<MetricCardWidget> createState() => _MetricCardWidgetState();
}

class _MetricCardWidgetState extends State<MetricCardWidget> {
  late MetricCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MetricCardModel());
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        lineHeight: 1.2,
                      ),
                ),
              ].divide(const SizedBox(width: 4)),
            ),
            Text(
              widget.value,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.5,
                  ),
            ),
            Text(
              widget.subtext,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: widget.subcolor.alpha > 0
                        ? widget.subcolor
                        : FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.4,
                  ),
            ),
          ].divide(const SizedBox(height: 4)),
        ),
      ),
    );
  }
}
