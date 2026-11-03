import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/button/button_model.dart';
import '../../components/feature_item/feature_item_model.dart';

class SplashOnboardingModel extends FlutterFlowModel<StatefulWidget> {
  late ButtonModel buttonModel1;
  late ButtonModel buttonModel2;
  late FeatureItemModel featureItemModel1;
  late FeatureItemModel featureItemModel2;
  late FeatureItemModel featureItemModel3;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    featureItemModel1 = createModel(context, () => FeatureItemModel());
    featureItemModel2 = createModel(context, () => FeatureItemModel());
    featureItemModel3 = createModel(context, () => FeatureItemModel());
  }

  @override
  void dispose() {
    buttonModel1.maybeDispose();
    buttonModel2.maybeDispose();
    featureItemModel1.maybeDispose();
    featureItemModel2.maybeDispose();
    featureItemModel3.maybeDispose();
  }
}
