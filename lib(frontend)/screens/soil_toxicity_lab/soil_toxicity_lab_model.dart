import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/bottom_nav/bottom_nav_model.dart';
import '../../components/bottom_nav_child/bottom_nav_child_model.dart';
import '../../components/button/button_model.dart';
import '../../components/metric_card2/metric_card2_model.dart';
import '../../components/toxicity_item/toxicity_item_model.dart';

class SoilToxicityLabModel extends FlutterFlowModel<StatefulWidget> {
  late BottomNavModel bottomNavModel;
  late BottomNavChildModel bottomNavChildModel;
  late ButtonModel buttonModel;
  late MetricCard2Model metricCardModel1;
  late MetricCard2Model metricCardModel2;
  late MetricCard2Model metricCardModel3;
  late MetricCard2Model metricCardModel4;
  late MetricCard2Model metricCardModel5;
  late MetricCard2Model metricCardModel6;
  late ToxicityItemModel toxicityItemModel1;
  late ToxicityItemModel toxicityItemModel2;
  late ToxicityItemModel toxicityItemModel3;

  @override
  void initState(BuildContext context) {
    bottomNavModel = createModel(context, () => BottomNavModel());
    bottomNavChildModel = createModel(context, () => BottomNavChildModel());
    buttonModel = createModel(context, () => ButtonModel());
    metricCardModel1 = createModel(context, () => MetricCard2Model());
    metricCardModel2 = createModel(context, () => MetricCard2Model());
    metricCardModel3 = createModel(context, () => MetricCard2Model());
    metricCardModel4 = createModel(context, () => MetricCard2Model());
    metricCardModel5 = createModel(context, () => MetricCard2Model());
    metricCardModel6 = createModel(context, () => MetricCard2Model());
    toxicityItemModel1 = createModel(context, () => ToxicityItemModel());
    toxicityItemModel2 = createModel(context, () => ToxicityItemModel());
    toxicityItemModel3 = createModel(context, () => ToxicityItemModel());
  }

  @override
  void dispose() {
    bottomNavModel.maybeDispose();
    bottomNavChildModel.maybeDispose();
    buttonModel.maybeDispose();
    metricCardModel1.maybeDispose();
    metricCardModel2.maybeDispose();
    metricCardModel3.maybeDispose();
    metricCardModel4.maybeDispose();
    metricCardModel5.maybeDispose();
    metricCardModel6.maybeDispose();
    toxicityItemModel1.maybeDispose();
    toxicityItemModel2.maybeDispose();
    toxicityItemModel3.maybeDispose();
  }
}
