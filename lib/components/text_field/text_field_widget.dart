import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'text_field_model.dart';
export 'text_field_model.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    String? label,
    bool? labelPresent,
    String? helper,
    bool? helperPresent,
    this.leadingIcon,
    bool? leadingIconPresent,
    this.trailingIcon,
    bool? trailingIconPresent,
    String? hint,
    String? value,
    String? onChange,
    String? onSubmit,
    String? variant,
    bool? error,
  })  : label = label ?? '',
        labelPresent = labelPresent ?? false,
        helper = helper ?? '',
        helperPresent = helperPresent ?? false,
        leadingIconPresent = leadingIconPresent ?? false,
        trailingIconPresent = trailingIconPresent ?? false,
        hint = hint ?? 'Enter value',
        value = value ?? '',
        onChange = onChange ?? '',
        onSubmit = onSubmit ?? '',
        variant = variant ?? 'outlined',
        error = error ?? false;

  final String label;
  final bool labelPresent;
  final String helper;
  final bool helperPresent;
  final Widget? leadingIcon;
  final bool leadingIconPresent;
  final Widget? trailingIcon;
  final bool trailingIconPresent;
  final String hint;
  final String value;
  final String onChange;
  final String onSubmit;
  final String variant;
  final bool error;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextFieldModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextFieldModel());
    _model.inputTextController ??=
        TextEditingController(text: widget.value);
    _model.inputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.error) return FlutterFlowTheme.of(context).error;
    if (widget.variant == 'filled' || widget.variant == 'ghost') {
      return Colors.transparent;
    }
    return FlutterFlowTheme.of(context).alternate;
  }

  double get _borderWidth {
    if (widget.variant == 'ghost') return 0;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelPresent && widget.label.isNotEmpty)
          Text(
            widget.label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(),
                  color: widget.error
                      ? FlutterFlowTheme.of(context).error
                      : FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: widget.variant == 'filled'
                ? FlutterFlowTheme.of(context).secondaryBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _borderColor, width: _borderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (widget.leadingIconPresent && widget.leadingIcon != null)
                  widget.leadingIcon!,
                Expanded(
                  child: TextFormField(
                    controller: _model.inputTextController,
                    focusNode: _model.inputFocusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hint,
                      hintStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).accent3,
                            letterSpacing: 0.0,
                          ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                        ),
                    validator: _model.inputTextControllerValidator
                        ?.asValidator(context),
                  ),
                ),
                if (widget.trailingIconPresent && widget.trailingIcon != null)
                  widget.trailingIcon!,
              ].divide(const SizedBox(width: 4)),
            ),
          ),
        ),
        if (widget.helperPresent && widget.helper.isNotEmpty)
          Text(
            widget.helper,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: widget.error
                      ? FlutterFlowTheme.of(context).error
                      : FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
      ].divide(const SizedBox(height: 6)),
    );
  }
}

// Extension to convert validator function to FormFieldValidator
extension ValidatorExtension
    on String? Function(BuildContext, String?)? {
  String? Function(String?)? asValidator(BuildContext context) {
    if (this == null) return null;
    return (val) => this!(context, val);
  }
}
