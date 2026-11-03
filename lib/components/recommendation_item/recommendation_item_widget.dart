import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'recommendation_item_model.dart';
export 'recommendation_item_model.dart';

class RecommendationItemWidget extends StatefulWidget {
  const RecommendationItemWidget({
    super.key,
    this.icon,
    String? title,
    Color? tone,
    String? value,
  })  : title = title ?? 'Soil Moisture',
        tone = tone ?? const Color(0x00000000),
        value = value ?? '28.4%';

  final Widget? icon;
  final String title;
  final Color tone;
  final String value;

  @override
  State<RecommendationItemWidget> createState() => _RecommendationItemWidgetState();
}

class _RecommendationItemWidgetState extends State<RecommendationItemWidget> {
  late RecommendationItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecommendationItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toneColor = widget.tone.alpha > 0
        ? widget.tone
        : FlutterFlowTheme.of(context).info;
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: toneColor.withAlpha(26),
                borderRadius: BorderRadius.circular(9999),
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
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    widget.value,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ].divide(const SizedBox(height: 2)),
              ),
            ),
          ].divide(const SizedBox(width: 16)),
        ),
      ),
    );
  }
}
