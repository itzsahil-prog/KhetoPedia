import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../nav_item/nav_item_widget.dart';
import 'bottom_nav_child2_model.dart';
export 'bottom_nav_child2_model.dart';

class BottomNavChild2Widget extends StatefulWidget {
  const BottomNavChild2Widget({super.key});

  @override
  State<BottomNavChild2Widget> createState() => _BottomNavChild2WidgetState();
}

class _BottomNavChild2WidgetState extends State<BottomNavChild2Widget> {
  late BottomNavChild2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomNavChild2Model());
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        wrapWithModel(
          model: _model.navItemModel1,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Home',
            icon: Icon(Icons.home_rounded,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            target: 'HomeDashboard',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel2,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Scan',
            icon: Icon(Icons.center_focus_strong_rounded,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            target: 'CropScanner',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel3,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Fields',
            icon: Icon(Icons.landscape_rounded,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            target: 'MyFields',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel4,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'Soil',
            icon: Icon(Icons.science_rounded,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            target: 'SoilToxicityLab',
            selected: false,
          ),
        ),
        wrapWithModel(
          model: _model.navItemModel5,
          updateCallback: () => safeSetState(() {}),
          child: NavItemWidget(
            label: 'AI',
            icon: Icon(Icons.psychology_rounded,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            target: 'AIAgriAssistant',
            selected: false,
          ),
        ),
      ],
    );
  }
}
