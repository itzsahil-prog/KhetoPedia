import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/guidance_step/guidance_step_model.dart';
import '../../components/scan_corner/scan_corner_model.dart';

class CropScannerModel extends FlutterFlowModel<StatefulWidget> {
  late ScanCornerModel scanCornerModel1;
  late ScanCornerModel scanCornerModel2;
  late ScanCornerModel scanCornerModel3;
  late ScanCornerModel scanCornerModel4;
  late GuidanceStepModel guidanceStepModel1;
  late GuidanceStepModel guidanceStepModel2;
  late GuidanceStepModel guidanceStepModel3;

  @override
  void initState(BuildContext context) {
    scanCornerModel1 = createModel(context, () => ScanCornerModel());
    scanCornerModel2 = createModel(context, () => ScanCornerModel());
    scanCornerModel3 = createModel(context, () => ScanCornerModel());
    scanCornerModel4 = createModel(context, () => ScanCornerModel());
    guidanceStepModel1 = createModel(context, () => GuidanceStepModel());
    guidanceStepModel2 = createModel(context, () => GuidanceStepModel());
    guidanceStepModel3 = createModel(context, () => GuidanceStepModel());
  }

  @override
  void dispose() {
    scanCornerModel1.maybeDispose();
    scanCornerModel2.maybeDispose();
    scanCornerModel3.maybeDispose();
    scanCornerModel4.maybeDispose();
    guidanceStepModel1.maybeDispose();
    guidanceStepModel2.maybeDispose();
    guidanceStepModel3.maybeDispose();
  }
}
