import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'chat_bubble_user_model.dart';
export 'chat_bubble_user_model.dart';

class ChatBubbleUserWidget extends StatefulWidget {
  const ChatBubbleUserWidget({
    super.key,
    String? message,
  }) : message =
            message ?? 'Why is my soil showing high EC in the latest report?';

  final String message;

  @override
  State<ChatBubbleUserWidget> createState() => _ChatBubbleUserWidgetState();
}

class _ChatBubbleUserWidgetState extends State<ChatBubbleUserWidget> {
  late ChatBubbleUserModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatBubbleUserModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.message,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).onPrimary,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondary,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              'JD',
              style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).onSecondary,
                    letterSpacing: 0.0,
                    lineHeight: 1.4,
                  ),
            ),
          ),
        ].divide(const SizedBox(width: 16)),
      ),
    );
  }
}
