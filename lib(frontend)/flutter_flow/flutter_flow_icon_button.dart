import 'package:flutter/material.dart';
import 'flutter_flow_theme.dart';

/// Drop-in replacement for FlutterFlow's FlutterFlowIconButton.
class FlutterFlowIconButton extends StatelessWidget {
  const FlutterFlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.buttonSize = 40,
    this.fillColor,
    this.borderRadius = 8,
    this.borderColor,
    this.borderWidth = 0,
    this.disabledColor,
    this.showLoadingIndicator = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final double buttonSize;
  final Color? fillColor;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? disabledColor;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: fillColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Container(
            decoration: borderWidth > 0
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: borderColor ?? Colors.transparent,
                      width: borderWidth,
                    ),
                  )
                : null,
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      ),
    );
  }
}
