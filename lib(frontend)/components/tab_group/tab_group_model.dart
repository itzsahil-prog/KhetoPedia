import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../tab_item/tab_item_model.dart';

class TabGroupModel extends FlutterFlowModel<StatefulWidget> {
  late TabItemModel tabItemModel1;
  late TabItemModel tabItemModel2;
  late TabItemModel tabItemModel3;
  late TabItemModel tabItemModel4;
  late TabItemModel tabItemModel5;

  @override
  void initState(BuildContext context) {
    tabItemModel1 = createModel(context, () => TabItemModel());
    tabItemModel2 = createModel(context, () => TabItemModel());
    tabItemModel3 = createModel(context, () => TabItemModel());
    tabItemModel4 = createModel(context, () => TabItemModel());
    tabItemModel5 = createModel(context, () => TabItemModel());
  }

  @override
  void dispose() {
    tabItemModel1.maybeDispose();
    tabItemModel2.maybeDispose();
    tabItemModel3.maybeDispose();
    tabItemModel4.maybeDispose();
    tabItemModel5.maybeDispose();
  }
}
