import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'scan_corner_model.dart';
export 'scan_corner_model.dart';

class ScanCornerWidget extends StatefulWidget {
  const ScanCornerWidget({
    super.key,
    double? radius,
    Color? side,
  })  : radius = radius ?? 0.0,
        side = side ?? const Color(0xFFFFFFFF);

  final double radius;
  final Color side;

  @override
  State<ScanCornerWidget> createState() => _ScanCornerWidgetState();
}

class _ScanCornerWidgetState extends State<ScanCornerWidget> {
  late ScanCornerModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScanCornerModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: widget.side, width: 3),
      ),
    );
  }
}
