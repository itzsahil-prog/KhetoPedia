import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'metric_card2_model.dart';
export 'metric_card2_model.dart';

class MetricCard2Widget extends StatefulWidget {
  const MetricCard2Widget({
    super.key,
    String? label,
    Color? tone,
    String? unit,
    String? value,
  })  : label = label ?? 'Nitrogen (N)',
        tone = tone ?? const Color(0x00000000),
        unit = unit ?? 'mg/kg',
        value = value ?? '42';

  final String label;
  final Color tone;
  final String unit;
  final String value;

  @override
  State<MetricCard2Widget> createState() => _MetricCard2WidgetState();
}

class _MetricCard2WidgetState extends State<MetricCard2Widget> {
  late MetricCard2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MetricCard2Model());
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
        border: Border.all(
            color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.2,
                  ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.value,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        lineHeight: 1.4,
                      ),
                ),
                Text(
                  widget.unit,
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        lineHeight: 1.2,
                      ),
                ),
              ].divide(const SizedBox(width: 4)),
            ),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: widget.tone.alpha > 0
                    ? widget.tone
                    : FlutterFlowTheme.of(context).success,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ].divide(const SizedBox(height: 4)),
        ),
      ),
    );
  }
}
