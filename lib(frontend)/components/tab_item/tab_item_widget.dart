import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'tab_item_model.dart';
export 'tab_item_model.dart';

class TabItemWidget extends StatefulWidget {
  const TabItemWidget({
    super.key,
    String? label,
    bool? selected,
  })  : label = label ?? 'Tab',
        selected = selected ?? false;

  final String label;
  final bool selected;

  @override
  State<TabItemWidget> createState() => _TabItemWidgetState();
}

class _TabItemWidgetState extends State<TabItemWidget> {
  late TabItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TabItemModel());
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
        color: widget.selected
            ? FlutterFlowTheme.of(context).secondary20
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.inter(),
                color: widget.selected
                    ? FlutterFlowTheme.of(context).onSurface
                    : FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                lineHeight: 1.3,
              ),
        ),
      ),
    );
  }
}
