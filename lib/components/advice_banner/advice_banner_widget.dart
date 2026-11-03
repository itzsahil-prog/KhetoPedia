import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'advice_banner_model.dart';
export 'advice_banner_model.dart';

class AdviceBannerWidget extends StatefulWidget {
  const AdviceBannerWidget({
    super.key,
    this.icon,
    String? message,
    String? status,
    Color? tone,
  })  : message = message ??
            'Soil moisture (28%) is below the optimal threshold (45%) for the Flowering stage.',
        status = status ?? 'Action Required',
        tone = tone ?? const Color(0xFFF57F17);

  final Widget? icon;
  final String message;
  final String status;
  final Color tone;

  @override
  State<AdviceBannerWidget> createState() => _AdviceBannerWidgetState();
}

class _AdviceBannerWidgetState extends State<AdviceBannerWidget> {
  late AdviceBannerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdviceBannerModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.tone.withAlpha(26);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.tone.withAlpha(77), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.icon ?? const SizedBox.shrink(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.status,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: widget.tone,
                          letterSpacing: 0.0,
                          lineHeight: 1.5,
                        ),
                  ),
                  Text(
                    widget.message,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          lineHeight: 1.4,
                        ),
                  ),
                ].divide(const SizedBox(height: 4)),
              ),
            ),
          ].divide(const SizedBox(width: 16)),
        ),
      ),
    );
  }
}
