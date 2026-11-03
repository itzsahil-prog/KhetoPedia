import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'quick_suggestion_model.dart';
export 'quick_suggestion_model.dart';

class QuickSuggestionWidget extends StatefulWidget {
  const QuickSuggestionWidget({
    super.key,
    this.icon,
    String? label,
  }) : label = label ?? 'Irrigation schedule?';

  final Widget? icon;
  final String label;

  @override
  State<QuickSuggestionWidget> createState() => _QuickSuggestionWidgetState();
}

class _QuickSuggestionWidgetState extends State<QuickSuggestionWidget> {
  late QuickSuggestionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuickSuggestionModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
              color: FlutterFlowTheme.of(context).alternate, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon ?? const SizedBox.shrink(),
              Text(
                widget.label,
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.4,
                    ),
              ),
            ].divide(const SizedBox(width: 8)),
          ),
        ),
      ),
    );
  }
}
