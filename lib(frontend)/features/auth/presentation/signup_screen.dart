import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/auth_state.dart';
import '../auth_providers.dart';
import 'widgets/auth_layout.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _phoneController   = TextEditingController();
  final _passController    = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _phoneFocus   = FocusNode();
  final _passFocus    = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isSubmitting   = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? _req(String? v, AppLocalizations l) =>
      (v == null || v.trim().isEmpty) ? l.authFieldRequired : null;

  String? _validateEmail(String? v, AppLocalizations l) {
    final req = _req(v, l);
    if (req != null) return req;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())) {
      return l.authInvalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? v, AppLocalizations l) {
    final req = _req(v, l);
    if (req != null) return req;
    if (v!.length < 8) return l.authPasswordTooShort;
    return null;
  }

  String? _validateConfirm(String? v, AppLocalizations l) {
    final req = _req(v, l);
    if (req != null) return req;
    if (v != _passController.text) return l.authPasswordsDoNotMatch;
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final phone = _phoneController.text.trim();
    await ref.read(authNotifierProvider.notifier).signup(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      password: _passController.text,
      phone:    phone.isEmpty ? null : phone,
    );

    if (mounted) setState(() => _isSubmitting = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final state = ref.watch(authNotifierProvider);

    final String? errorMessage = switch (state) {
      AuthStateError(:final failure) => failure.message,
      _                              => null,
    };

    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthBrand(headline: l.authCreateAccount, subhead: l.appName),
            const SizedBox(height: 32),

            if (errorMessage != null) ...[
              AuthErrorBanner(message: errorMessage),
              const SizedBox(height: 16),
            ],

            // ── Full name ────────────────────────────────────────────────
            _buildField(
              controller: _nameController,
              focusNode:  _nameFocus,
              label:      l.authFullName,
              hint:       l.authFullNameHint,
              keyboard:   TextInputType.name,
              hints:      const [AutofillHints.name],
              icon:       const Icon(Icons.person_outline_rounded, size: 20),
              onNext:     () => _emailFocus.requestFocus(),
              validator:  (v) => _req(v, l),
            ),
            const SizedBox(height: 16),

            // ── Email ────────────────────────────────────────────────────
            _buildField(
              controller: _emailController,
              focusNode:  _emailFocus,
              label:      l.authEmail,
              hint:       l.authEmailHint,
              keyboard:   TextInputType.emailAddress,
              hints:      const [AutofillHints.email],
              icon:       const Icon(Icons.email_outlined, size: 20),
              onNext:     () => _phoneFocus.requestFocus(),
              validator:  (v) => _validateEmail(v, l),
            ),
            const SizedBox(height: 16),

            // ── Phone (optional) ─────────────────────────────────────────
            _buildField(
              controller:      _phoneController,
              focusNode:       _phoneFocus,
              label:           l.authPhone,
              hint:            l.authPhoneHint,
              keyboard:        TextInputType.phone,
              hints:           const [AutofillHints.telephoneNumber],
              icon:            const Icon(Icons.phone_outlined, size: 20),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              ],
              onNext:    () => _passFocus.requestFocus(),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),

            // ── Password ─────────────────────────────────────────────────
            FormField<String>(
              validator: (_) => _validatePassword(_passController.text, l),
              builder: (field) => AuthPasswordField(
                controller:      _passController,
                focusNode:       _passFocus,
                label:           l.authPassword,
                hint:            l.authPasswordHint,
                obscure:         _obscurePass,
                onToggleObscure: () =>
                    setState(() => _obscurePass = !_obscurePass),
                textInputAction: TextInputAction.next,
                autofillHints:   const [AutofillHints.newPassword],
                errorText:       field.errorText,
                onSubmitted:     (_) => _confirmFocus.requestFocus(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Confirm password ──────────────────────────────────────────
            FormField<String>(
              validator: (_) => _validateConfirm(_confirmController.text, l),
              builder: (field) => AuthPasswordField(
                controller:      _confirmController,
                focusNode:       _confirmFocus,
                label:           l.authConfirmPassword,
                hint:            l.authConfirmPasswordHint,
                obscure:         _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                textInputAction: TextInputAction.done,
                autofillHints:   const [AutofillHints.newPassword],
                errorText:       field.errorText,
                onSubmitted:     (_) => _submit(),
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              label:     l.authSignUp,
              size:      AppButtonSize.large,
              fullWidth: true,
              loading:   _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 32),

            AuthTextLink(
              prefix: l.authHaveAccount,
              label:  l.authLogin,
              onTap:  () => context.goNamed(AppRoutes.login),
            ),
            const SizedBox(height: 24),

            AuthLegalText(l: l),
          ],
        ),
      ),
    );
  }

  /// Builds a [FormField]-wrapped [AppTextField] for text inputs.
  Widget _buildField({
    required TextEditingController       controller,
    required FocusNode                   focusNode,
    required String                      label,
    required String                      hint,
    required FormFieldValidator<String>  validator,
    TextInputType?                       keyboard,
    Iterable<String>?                    hints,
    Widget?                              icon,
    List<TextInputFormatter>?            inputFormatters,
    VoidCallback?                        onNext,
  }) {
    return FormField<String>(
      validator: (_) => validator(controller.text),
      builder: (field) => AppTextField(
        controller:      controller,
        focusNode:       focusNode,
        label:           label,
        hint:            hint,
        keyboardType:    keyboard,
        textInputAction: TextInputAction.next,
        autofillHints:   hints,
        leading:         icon,
        inputFormatters: inputFormatters,
        errorText:       field.errorText,
        onChanged:       (_) => field.didChange(controller.text),
        onSubmitted:     (_) => onNext?.call(),
        semanticLabel:   label,
      ),
    );
  }
}
