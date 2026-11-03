import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'farm_stat_card_model.dart';
export 'farm_stat_card_model.dart';

class FarmStatCardWidget extends StatefulWidget {
  const FarmStatCardWidget({
    super.key,
    String? label,
    String? value,
  })  : label = label ?? 'Registered Fields',
        value = value ?? '3';

  final String label;
  final String value;

  @override
  State<FarmStatCardWidget> createState() => _FarmStatCardWidgetState();
}

class _FarmStatCardWidgetState extends State<FarmStatCardWidget> {
  late FarmStatCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FarmStatCardModel());
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              widget.label,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.2,
                  ),
            ),
          ].divide(const SizedBox(height: 4)),
        ),
      ),
    );
  }
}
