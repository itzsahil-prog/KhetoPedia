import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'action_step_model.dart';
export 'action_step_model.dart';

class ActionStepWidget extends StatefulWidget {
  const ActionStepWidget({
    super.key,
    Color? bg,
    String? description,
    String? number,
    Color? textColor,
    String? title,
  })  : bg = bg ?? const Color(0xFFE3F2FD),
        description = description ?? 'Prevent spread by limiting movement in the infected zone.',
        number = number ?? '1',
        textColor = textColor ?? const Color(0xFF1565C0),
        title = title ?? 'Isolate Affected Area';

  final Color bg;
  final String description;
  final String number;
  final Color textColor;
  final String title;

  @override
  State<ActionStepWidget> createState() => _ActionStepWidgetState();
}

class _ActionStepWidgetState extends State<ActionStepWidget> {
  late ActionStepModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActionStepModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(9999),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.number,
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: widget.textColor,
                  letterSpacing: 0.0,
                  lineHeight: 1.4,
                ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.5,
                    ),
              ),
              Text(
                widget.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.4,
                    ),
              ),
            ].divide(const SizedBox(height: 4)),
          ),
        ),
      ].divide(const SizedBox(width: 16)),
    );
  }
}
