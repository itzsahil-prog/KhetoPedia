import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class TextFieldModel extends FlutterFlowModel<StatefulWidget> {
  TextEditingController? inputTextController;
  FocusNode? inputFocusNode;
  String? Function(BuildContext, String?)? inputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    inputTextControllerValidator = (ctx, val) => null;
  }

  @override
  void dispose() {
    inputFocusNode?.dispose();
    inputTextController?.dispose();
  }
}
