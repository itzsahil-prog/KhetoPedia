import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/action_step/action_step_model.dart';
import '../../components/button/button_model.dart';
import '../../components/metric_badge/metric_badge_model.dart';
import '../../components/severity_indicator/severity_indicator_model.dart';

class AnalysisResultsModel extends FlutterFlowModel<StatefulWidget> {
  late SeverityIndicatorModel severityIndicatorModel;
  late ButtonModel buttonModel1;
  late ButtonModel buttonModel2;
  late MetricBadgeModel metricBadgeModel1;
  late MetricBadgeModel metricBadgeModel2;
  late MetricBadgeModel metricBadgeModel3;
  late ActionStepModel actionStepModel1;
  late ActionStepModel actionStepModel2;
  late ActionStepModel actionStepModel3;

  @override
  void initState(BuildContext context) {
    severityIndicatorModel = createModel(context, () => SeverityIndicatorModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    metricBadgeModel1 = createModel(context, () => MetricBadgeModel());
    metricBadgeModel2 = createModel(context, () => MetricBadgeModel());
    metricBadgeModel3 = createModel(context, () => MetricBadgeModel());
    actionStepModel1 = createModel(context, () => ActionStepModel());
    actionStepModel2 = createModel(context, () => ActionStepModel());
    actionStepModel3 = createModel(context, () => ActionStepModel());
  }

  @override
  void dispose() {
    severityIndicatorModel.maybeDispose();
    buttonModel1.maybeDispose();
    buttonModel2.maybeDispose();
    metricBadgeModel1.maybeDispose();
    metricBadgeModel2.maybeDispose();
    metricBadgeModel3.maybeDispose();
    actionStepModel1.maybeDispose();
    actionStepModel2.maybeDispose();
    actionStepModel3.maybeDispose();
  }
}
