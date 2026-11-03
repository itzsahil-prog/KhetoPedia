import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/button/button_model.dart';
import '../../components/field_card/field_card_model.dart';

class MyFieldsModel extends FlutterFlowModel<StatefulWidget> {
  late ButtonModel buttonModel;
  late FieldCardModel fieldCardModel1;
  late FieldCardModel fieldCardModel2;
  late FieldCardModel fieldCardModel3;

  @override
  void initState(BuildContext context) {
    buttonModel = createModel(context, () => ButtonModel());
    fieldCardModel1 = createModel(context, () => FieldCardModel());
    fieldCardModel2 = createModel(context, () => FieldCardModel());
    fieldCardModel3 = createModel(context, () => FieldCardModel());
  }

  @override
  void dispose() {
    buttonModel.maybeDispose();
    fieldCardModel1.maybeDispose();
    fieldCardModel2.maybeDispose();
    fieldCardModel3.maybeDispose();
  }
}
