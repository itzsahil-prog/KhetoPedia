import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'chat_bubble_ai_model.dart';
export 'chat_bubble_ai_model.dart';

class ChatBubbleAiWidget extends StatefulWidget {
  const ChatBubbleAiWidget({
    super.key,
    String? dataText,
    bool? hasData,
    String? message,
  })  : dataText = dataText ?? 'Field Status: Optimal',
        hasData = hasData ?? true,
        message = message ??
            'Hello! How can I help you with your farm today?';

  final String dataText;
  final bool hasData;
  final String message;

  @override
  State<ChatBubbleAiWidget> createState() => _ChatBubbleAiWidgetState();
}

class _ChatBubbleAiWidgetState extends State<ChatBubbleAiWidget> {
  late ChatBubbleAiModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatBubbleAiModel());
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.agriculture_rounded,
                color: FlutterFlowTheme.of(context).onPrimary, size: 20),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.message,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                ),
                if (widget.hasData)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFC8E6C9), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 8, 16, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.assessment_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 16),
                            Text(
                              widget.dataText,
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.2,
                                  ),
                            ),
                          ].divide(const SizedBox(width: 8)),
                        ),
                      ),
                    ),
                  ),
              ].divide(const SizedBox(height: 4)),
            ),
          ),
        ].divide(const SizedBox(width: 16)),
      ),
    );
  }
}
