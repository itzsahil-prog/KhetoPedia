import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'guidance_step_model.dart';
export 'guidance_step_model.dart';

class GuidanceStepWidget extends StatefulWidget {
  const GuidanceStepWidget({
    super.key,
    this.icon,
    String? label,
    bool? active,
  })  : label = label ?? 'Lighting',
        active = active ?? true;

  final Widget? icon;
  final String label;
  final bool active;

  @override
  State<GuidanceStepWidget> createState() => _GuidanceStepWidgetState();
}

class _GuidanceStepWidgetState extends State<GuidanceStepWidget> {
  late GuidanceStepModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GuidanceStepModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.active
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).surface20,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: widget.active
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).onPrimary30,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: widget.icon ?? const SizedBox.shrink(),
        ),
        Text(
          widget.label,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                color: FlutterFlowTheme.of(context).onPrimary,
                letterSpacing: 0.0,
                lineHeight: 1.2,
              ),
        ),
      ].divide(const SizedBox(height: 4)),
    );
  }
}
