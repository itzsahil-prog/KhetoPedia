import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'alert_item_model.dart';
export 'alert_item_model.dart';

class AlertItemWidget extends StatefulWidget {
  const AlertItemWidget({
    super.key,
    Color? bg,
    String? desc,
    this.icon,
    Color? iconColor,
    String? title,
  })  : bg = bg ?? const Color(0xFFFFF3E0),
        desc = desc ??
            'Soil moisture dropped below 25% in the North sector.',
        iconColor = iconColor ?? const Color(0xFFE65100),
        title = title ?? 'Low Moisture Detected';

  final Color bg;
  final String desc;
  final Widget? icon;
  final Color iconColor;
  final String title;

  @override
  State<AlertItemWidget> createState() => _AlertItemWidgetState();
}

class _AlertItemWidgetState extends State<AlertItemWidget> {
  late AlertItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon ?? const SizedBox.shrink(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold),
                                color: widget.iconColor,
                                letterSpacing: 0.0,
                                lineHeight: 1.5,
                              ),
                    ),
                    Opacity(
                      opacity: 0.9,
                      child: Text(
                        widget.desc,
                        style:
                            FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: widget.iconColor,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.4,
                                ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 2)),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: widget.iconColor, size: 20),
            ].divide(const SizedBox(width: 16)),
          ),
        ),
      ),
    );
  }
}
