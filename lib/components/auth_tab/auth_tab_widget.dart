import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'auth_tab_model.dart';
export 'auth_tab_model.dart';

class AuthTabWidget extends StatefulWidget {
  const AuthTabWidget({
    super.key,
    String? active,
    String? label,
  })  : active = active ?? 'true',
        label = label ?? 'Login';

  final String active;
  final String label;

  @override
  State<AuthTabWidget> createState() => _AuthTabWidgetState();
}

class _AuthTabWidgetState extends State<AuthTabWidget> {
  late AuthTabModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthTabModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.active != 'false';
    return Container(
      decoration: const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: isActive
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}
