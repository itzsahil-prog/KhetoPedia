import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'button_model.dart';
export 'button_model.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    this.icon,
    bool? iconPresent,
    this.iconEnd,
    bool? iconEndPresent,
    String? content,
    String? variant,
    String? size,
    bool? fullWidth,
    bool? loading,
    bool? disabled,
  })  : iconPresent = iconPresent ?? true,
        iconEndPresent = iconEndPresent ?? false,
        content = content ?? 'Get Started',
        variant = variant ?? 'primary',
        size = size ?? 'large',
        fullWidth = fullWidth ?? true,
        loading = loading ?? false,
        disabled = disabled ?? false;

  final Widget? icon;
  final bool iconPresent;
  final Widget? iconEnd;
  final bool iconEndPresent;
  final String content;
  final String variant;
  final String size;
  final bool fullWidth;
  final bool loading;
  final bool disabled;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late ButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.variant) {
      case 'secondary':
        return FlutterFlowTheme.of(context).secondary;
      case 'outline':
      case 'ghost':
        return Colors.transparent;
      case 'destructive':
        return FlutterFlowTheme.of(context).error;
      default:
        return FlutterFlowTheme.of(context).primary;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case 'secondary':
        return FlutterFlowTheme.of(context).onSecondary;
      case 'outline':
        return FlutterFlowTheme.of(context).primaryText;
      case 'ghost':
        return FlutterFlowTheme.of(context).primary;
      case 'destructive':
        return FlutterFlowTheme.of(context).onError;
      default:
        return FlutterFlowTheme.of(context).onPrimary;
    }
  }

  double get _radius {
    switch (widget.size) {
      case 'small':
        return 4;
      case 'large':
        return 12;
      default:
        return 8;
    }
  }

  EdgeInsetsDirectional get _padding {
    switch (widget.size) {
      case 'small':
        return const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4);
      case 'large':
        return const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 16);
      default:
        return const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled ? 0.55 : 1.0,
      child: Container(
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(_radius),
          border: widget.variant == 'outline'
              ? Border.all(
                  color: FlutterFlowTheme.of(context).alternate, width: 1)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: widget.loading ? 0.0 : 1.0,
              child: Padding(
                padding: _padding,
                child: Row(
                  mainAxisSize:
                      widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.iconPresent && widget.icon != null) widget.icon!,
                    Text(
                      widget.content,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: FlutterFlowTheme.of(context)
                          .labelMedium
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                            ),
                            color: _textColor,
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (widget.iconEndPresent && widget.iconEnd != null)
                      widget.iconEnd!,
                  ].divide(const SizedBox(width: 8)),
                ),
              ),
            ),
            if (widget.loading)
              CircularPercentIndicator(
                percent: 0,
                radius: 7,
                lineWidth: 2,
                animation: true,
                animateFromLastPercent: true,
                progressColor: _textColor,
                backgroundColor: FlutterFlowTheme.of(context).alternate,
              ),
          ],
        ),
      ),
    );
  }
}
