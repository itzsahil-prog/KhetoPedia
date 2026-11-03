import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/chat_bubble_ai/chat_bubble_ai_model.dart';
import '../../components/chat_bubble_user/chat_bubble_user_model.dart';
import '../../components/quick_suggestion/quick_suggestion_model.dart';
import '../../components/text_field/text_field_model.dart';

class AIAgriAssistantModel extends FlutterFlowModel<StatefulWidget> {
  late ChatBubbleAiModel chatBubbleAiModel1;
  late ChatBubbleAiModel chatBubbleAiModel2;
  late ChatBubbleAiModel chatBubbleAiModel3;
  late ChatBubbleUserModel chatBubbleUserModel1;
  late ChatBubbleUserModel chatBubbleUserModel2;
  late QuickSuggestionModel quickSuggestionModel1;
  late QuickSuggestionModel quickSuggestionModel2;
  late QuickSuggestionModel quickSuggestionModel3;
  late TextFieldModel textFieldModel;

  @override
  void initState(BuildContext context) {
    chatBubbleAiModel1 = createModel(context, () => ChatBubbleAiModel());
    chatBubbleAiModel2 = createModel(context, () => ChatBubbleAiModel());
    chatBubbleAiModel3 = createModel(context, () => ChatBubbleAiModel());
    chatBubbleUserModel1 = createModel(context, () => ChatBubbleUserModel());
    chatBubbleUserModel2 = createModel(context, () => ChatBubbleUserModel());
    quickSuggestionModel1 = createModel(context, () => QuickSuggestionModel());
    quickSuggestionModel2 = createModel(context, () => QuickSuggestionModel());
    quickSuggestionModel3 = createModel(context, () => QuickSuggestionModel());
    textFieldModel = createModel(context, () => TextFieldModel());
  }

  @override
  void dispose() {
    chatBubbleAiModel1.maybeDispose();
    chatBubbleAiModel2.maybeDispose();
    chatBubbleAiModel3.maybeDispose();
    chatBubbleUserModel1.maybeDispose();
    chatBubbleUserModel2.maybeDispose();
    quickSuggestionModel1.maybeDispose();
    quickSuggestionModel2.maybeDispose();
    quickSuggestionModel3.maybeDispose();
    textFieldModel.maybeDispose();
  }
}
