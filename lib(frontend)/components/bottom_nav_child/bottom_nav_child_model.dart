import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../nav_item/nav_item_model.dart';

class BottomNavChildModel extends FlutterFlowModel<StatefulWidget> {
  late NavItemModel navItemModel1;
  late NavItemModel navItemModel2;
  late NavItemModel navItemModel3;
  late NavItemModel navItemModel4;
  late NavItemModel navItemModel5;

  @override
  void initState(BuildContext context) {
    navItemModel1 = createModel(context, () => NavItemModel());
    navItemModel2 = createModel(context, () => NavItemModel());
    navItemModel3 = createModel(context, () => NavItemModel());
    navItemModel4 = createModel(context, () => NavItemModel());
    navItemModel5 = createModel(context, () => NavItemModel());
  }

  @override
  void dispose() {
    navItemModel1.maybeDispose();
    navItemModel2.maybeDispose();
    navItemModel3.maybeDispose();
    navItemModel4.maybeDispose();
    navItemModel5.maybeDispose();
  }
}
