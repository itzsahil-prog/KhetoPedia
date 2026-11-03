import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';

/// Accessible text field with label, hint, error, leading/trailing widgets.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.leading,
    this.trailing,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText  = false,
    this.readOnly     = false,
    this.enabled      = true,
    this.maxLines     = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofillHints,
    this.semanticLabel,
  });

  final TextEditingController?       controller;
  final FocusNode?                   focusNode;
  final String?                      label;
  final String?                      hint;
  final String?                      helperText;
  final String?                      errorText;
  final Widget?                      leading;
  final Widget?                      trailing;
  final IconData?                    prefixIcon;
  final IconData?                    suffixIcon;
  final bool                         obscureText;
  final bool                         readOnly;
  final bool                         enabled;
  final int                          maxLines;
  final TextInputType?               keyboardType;
  final TextInputAction?             textInputAction;
  final List<TextInputFormatter>?    inputFormatters;
  final String? Function(String?)?   validator;
  final ValueChanged<String>?        onChanged;
  final ValueChanged<String>?        onSubmitted;
  final VoidCallback?                onTap;
  final Iterable<String>?            autofillHints;
  final String?                      semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final cs      = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final Widget? leadingWidget = leading ?? (prefixIcon != null ? Icon(prefixIcon) : null);
    final Widget? trailingWidget = trailing ?? (suffixIcon != null ? Icon(suffixIcon) : null);

    // Use TextFormField if validator is provided, otherwise TextField
    if (validator != null) {
      return Semantics(
        label:     semanticLabel ?? label,
        textField: true,
        child: TextFormField(
          controller:         controller,
          focusNode:          focusNode,
          obscureText:        obscureText,
          readOnly:           readOnly,
          enabled:            enabled,
          maxLines:           maxLines,
          keyboardType:       keyboardType,
          textInputAction:    textInputAction,
          inputFormatters:    inputFormatters,
          validator:          validator,
          onChanged:          onChanged,
          onFieldSubmitted:   onSubmitted,
          onTap:              onTap,
          autofillHints:      autofillHints,
          style:              AppTextStyles.bodyMedium(cs.onSurface),
          decoration: InputDecoration(
            labelText:    label,
            hintText:     hint,
            helperText:   helperText,
            errorText:    hasError ? errorText : null,
            prefixIcon:   leadingWidget,
            suffixIcon:   trailingWidget,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(
                color: hasError ? cs.error : cs.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? cs.error : cs.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.error, width: 2),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label:     semanticLabel ?? label,
      textField: true,
      child: TextField(
        controller:         controller,
        focusNode:          focusNode,
        obscureText:        obscureText,
        readOnly:           readOnly,
        enabled:            enabled,
        maxLines:           maxLines,
        keyboardType:       keyboardType,
        textInputAction:    textInputAction,
        inputFormatters:    inputFormatters,
        onChanged:          onChanged,
        onSubmitted:        onSubmitted,
        onTap:              onTap,
        autofillHints:      autofillHints,
        style:              AppTextStyles.bodyMedium(cs.onSurface),
        decoration: InputDecoration(
          labelText:    label,
          hintText:     hint,
          helperText:   helperText,
          errorText:    hasError ? errorText : null,
          prefixIcon:   leadingWidget,
          suffixIcon:   trailingWidget,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   BorderSide(
              color: hasError ? cs.error : cs.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError ? cs.error : cs.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.error, width: 2),
          ),
        ),
      ),
    );
  }
}
