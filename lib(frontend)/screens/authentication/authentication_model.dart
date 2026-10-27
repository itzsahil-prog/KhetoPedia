import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/auth_tab/auth_tab_model.dart';
import '../../components/button/button_model.dart';
import '../../components/text_field/text_field_model.dart';
import '../../components/social_btn/social_btn_model.dart';

class AuthenticationModel extends FlutterFlowModel<StatefulWidget> {
  late AuthTabModel authTabModel1;
  late AuthTabModel authTabModel2;
  late ButtonModel buttonModel1;
  late ButtonModel buttonModel2;
  late TextFieldModel textFieldModel1;
  late TextFieldModel textFieldModel2;
  late TextFieldModel textFieldModel3;
  late SocialBtnModel socialBtnModel1;
  late SocialBtnModel socialBtnModel2;

  @override
  void initState(BuildContext context) {
    authTabModel1 = createModel(context, () => AuthTabModel());
    authTabModel2 = createModel(context, () => AuthTabModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    socialBtnModel1 = createModel(context, () => SocialBtnModel());
    socialBtnModel2 = createModel(context, () => SocialBtnModel());
  }

  @override
  void dispose() {
    authTabModel1.maybeDispose();
    authTabModel2.maybeDispose();
    buttonModel1.maybeDispose();
    buttonModel2.maybeDispose();
    textFieldModel1.maybeDispose();
    textFieldModel2.maybeDispose();
    textFieldModel3.maybeDispose();
    socialBtnModel1.maybeDispose();
    socialBtnModel2.maybeDispose();
  }
}
