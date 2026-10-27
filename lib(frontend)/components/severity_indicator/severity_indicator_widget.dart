import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'severity_indicator_model.dart';
export 'severity_indicator_model.dart';

class SeverityIndicatorWidget extends StatefulWidget {
  const SeverityIndicatorWidget({
    super.key,
    Color? bg,
    Color? dotColor,
    String? label,
    Color? textColor,
  })  : bg = bg ?? const Color(0xFFFFF4E5),
        dotColor = dotColor ?? const Color(0xFFF57C00),
        label = label ?? 'MODERATE',
        textColor = textColor ?? const Color(0xFFE65100);

  final Color bg;
  final Color dotColor;
  final String label;
  final Color textColor;

  @override
  State<SeverityIndicatorWidget> createState() => _SeverityIndicatorWidgetState();
}

class _SeverityIndicatorWidgetState extends State<SeverityIndicatorWidget> {
  late SeverityIndicatorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SeverityIndicatorModel());
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
        color: widget.bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.dotColor,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.textColor,
              ),
            ),
          ].divide(const SizedBox(width: 4)),
        ),
      ),
    );
  }
}
