import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'profile_option_model.dart';
export 'profile_option_model.dart';

class ProfileOptionWidget extends StatefulWidget {
  const ProfileOptionWidget({
    super.key,
    Color? bgColor,
    this.icon,
    Color? iconColor,
    String? subtitle,
    String? title,
  })  : bgColor = bgColor ?? const Color(0x00000000),
        iconColor = iconColor ?? const Color(0x00000000),
        subtitle = subtitle ?? 'Name, Phone, and Address',
        title = title ?? 'Edit Profile';

  final Color bgColor;
  final Widget? icon;
  final Color iconColor;
  final String subtitle;
  final String title;

  @override
  State<ProfileOptionWidget> createState() => _ProfileOptionWidgetState();
}

class _ProfileOptionWidgetState extends State<ProfileOptionWidget> {
  late ProfileOptionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileOptionModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.bgColor.alpha > 0
        ? widget.bgColor
        : FlutterFlowTheme.of(context).primaryContainer;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: widget.icon ?? const SizedBox.shrink(),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(const SizedBox(height: 2)),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: FlutterFlowTheme.of(context).accent3, size: 20),
            ].divide(const SizedBox(width: 16)),
          ),
        ),
      ),
    );
  }
}
