import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/alert_item/alert_item_model.dart';
import '../../components/metric_card/metric_card_model.dart';
import '../../components/quick_action/quick_action_model.dart';

class HomeDashboardModel extends FlutterFlowModel<StatefulWidget> {
  late AlertItemModel alertItemModel1;
  late AlertItemModel alertItemModel2;
  late MetricCardModel metricCardModel1;
  late MetricCardModel metricCardModel2;
  late MetricCardModel metricCardModel3;
  late MetricCardModel metricCardModel4;
  late QuickActionModel quickActionModel1;
  late QuickActionModel quickActionModel2;
  late QuickActionModel quickActionModel3;
  late QuickActionModel quickActionModel4;

  @override
  void initState(BuildContext context) {
    alertItemModel1 = createModel(context, () => AlertItemModel());
    alertItemModel2 = createModel(context, () => AlertItemModel());
    metricCardModel1 = createModel(context, () => MetricCardModel());
    metricCardModel2 = createModel(context, () => MetricCardModel());
    metricCardModel3 = createModel(context, () => MetricCardModel());
    metricCardModel4 = createModel(context, () => MetricCardModel());
    quickActionModel1 = createModel(context, () => QuickActionModel());
    quickActionModel2 = createModel(context, () => QuickActionModel());
    quickActionModel3 = createModel(context, () => QuickActionModel());
    quickActionModel4 = createModel(context, () => QuickActionModel());
  }

  @override
  void dispose() {
    alertItemModel1.maybeDispose();
    alertItemModel2.maybeDispose();
    metricCardModel1.maybeDispose();
    metricCardModel2.maybeDispose();
    metricCardModel3.maybeDispose();
    metricCardModel4.maybeDispose();
    quickActionModel1.maybeDispose();
    quickActionModel2.maybeDispose();
    quickActionModel3.maybeDispose();
    quickActionModel4.maybeDispose();
  }
}
