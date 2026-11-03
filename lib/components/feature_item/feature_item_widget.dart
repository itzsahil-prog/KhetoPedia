import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'feature_item_model.dart';
export 'feature_item_model.dart';

class FeatureItemWidget extends StatefulWidget {
  const FeatureItemWidget({
    super.key,
    String? description,
    this.icon,
    String? title,
  })  : description = description ??
            'Identify pests and diseases in seconds with our advanced vision AI.',
        title = title ?? 'AI Disease Detection';

  final String description;
  final Widget? icon;
  final String title;

  @override
  State<FeatureItemWidget> createState() => _FeatureItemWidgetState();
}

class _FeatureItemWidgetState extends State<FeatureItemWidget> {
  late FeatureItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeatureItemModel());
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: FlutterFlowTheme.of(context).alternate, width: 1),
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
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
