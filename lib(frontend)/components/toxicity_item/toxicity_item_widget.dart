import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'toxicity_item_model.dart';
export 'toxicity_item_model.dart';

class ToxicityItemWidget extends StatefulWidget {
  const ToxicityItemWidget({
    super.key,
    String? date,
    String? element,
    String? limit,
    String? measured,
    String? status,
    Color? tone,
  })  : date = date ?? '18 Sep 2023',
        element = element ?? 'Cadmium (Cd)',
        limit = limit ?? '0.10 mg/kg',
        measured = measured ?? '0.02 mg/kg',
        status = status ?? 'Normal',
        tone = tone ?? const Color(0xFF388E3C);

  final String date;
  final String element;
  final String limit;
  final String measured;
  final String status;
  final Color tone;

  @override
  State<ToxicityItemWidget> createState() => _ToxicityItemWidgetState();
}

class _ToxicityItemWidgetState extends State<ToxicityItemWidget> {
  late ToxicityItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ToxicityItemModel());
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
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.element,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      'Tested: ${widget.date}',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(const SizedBox(height: 2)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.tone.withAlpha(26),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
                    child: Text(
                      widget.status,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: widget.tone,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Measured Value',
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              )),
                      Text(widget.measured,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              )),
                    ].divide(const SizedBox(height: 4)),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Reference Limit',
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              )),
                      Text(widget.limit,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              )),
                    ].divide(const SizedBox(height: 4)),
                  ),
                ),
              ].divide(const SizedBox(width: 24)),
            ),
            Divider(color: FlutterFlowTheme.of(context).alternate, height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_rounded, color: FlutterFlowTheme.of(context).info, size: 14),
                Text('Source: Central Agri Laboratory',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        )),
              ].divide(const SizedBox(width: 4)),
            ),
          ].divide(const SizedBox(height: 12)),
        ),
      ),
    );
  }
}
