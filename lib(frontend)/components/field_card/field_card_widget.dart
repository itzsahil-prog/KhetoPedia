import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'field_card_model.dart';
export 'field_card_model.dart';

class FieldCardWidget extends StatefulWidget {
  const FieldCardWidget({
    super.key,
    String? acreage,
    String? cropName,
    String? fieldName,
    String? health,
    String? plantDate,
    String? status,
    String? trend,
  })  : acreage = acreage ?? '4.2',
        cropName = cropName ?? 'Golden Wheat',
        fieldName = fieldName ?? 'North Sector A1',
        health = health ?? '88',
        plantDate = plantDate ?? 'Oct 12, 2023',
        status = status ?? 'healthy',
        trend = trend ?? '70,75,82,85,88';

  final String acreage;
  final String cropName;
  final String fieldName;
  final String health;
  final String plantDate;
  final String status;
  final String trend;

  @override
  State<FieldCardWidget> createState() => _FieldCardWidgetState();
}

class _FieldCardWidgetState extends State<FieldCardWidget> {
  late FieldCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FieldCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  bool get _isHealthy => widget.status == 'healthy';

  List<double> get _trendValues {
    return widget.trend
        .split(',')
        .map((v) => double.tryParse(v.trim()) ?? 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cropName,
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                        Text(
                          widget.fieldName,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(const SizedBox(height: 2)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: _isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6),
                      child: Text(
                        widget.status,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              color: _isHealthy
                                  ? FlutterFlowTheme.of(context).success
                                  : const Color(0xFFE65100),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.landscape_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText, size: 16),
                        Text(
                          '${widget.acreage} Acres',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(const SizedBox(width: 4)),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 16),
                        Text(
                          'Moisture: 64%',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(const SizedBox(width: 4)),
                    ),
                  ),
                ].divide(const SizedBox(width: 24)),
              ),
              Divider(color: FlutterFlowTheme.of(context).alternate, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planted: ${widget.plantDate}',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        'Health Score: ${widget.health}/100',
                        style: FlutterFlowTheme.of(context).labelMedium.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(const SizedBox(height: 2)),
                  ),
                  // Mini sparkline using CustomPaint
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        values: _trendValues,
                        color: _isHealthy
                            ? FlutterFlowTheme.of(context).success
                            : FlutterFlowTheme.of(context).tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ].divide(const SizedBox(height: 16)),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min == 0 ? 1.0 : max - min;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values || old.color != color;
}
