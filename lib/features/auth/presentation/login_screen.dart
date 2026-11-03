import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/auth_state.dart';
import '../auth_providers.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  final _emailFocus      = FocusNode();
  final _passFocus       = FocusNode();
  bool  _obscurePassword = true;
  bool  _isSubmitting    = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? _validateEmail(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.authFieldRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return l.authInvalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? v, AppLocalizations l) {
    if (v == null || v.isEmpty) return l.authFieldRequired;
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    await ref.read(authNotifierProvider.notifier).login(
      email:    _emailController.text.trim(),
      password: _passController.text,
    );

    if (mounted) setState(() => _isSubmitting = false);
    // Router redirect guard handles navigation on success.
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final state = ref.watch(authNotifierProvider);
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;

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
            AuthBrand(headline: l.authWelcomeBack, subhead: l.appName),
            const SizedBox(height: 40),

            if (errorMessage != null) ...[
              AuthErrorBanner(message: errorMessage),
              const SizedBox(height: 16),
            ],

            // ── Email ────────────────────────────────────────────────────
            FormField<String>(
              validator: (_) => _validateEmail(_emailController.text, l),
              builder: (field) => AppTextField(
                controller:      _emailController,
                focusNode:       _emailFocus,
                label:           l.authEmail,
                hint:            l.authEmailHint,
                keyboardType:    TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints:   const [AutofillHints.email],
                errorText:       field.errorText,
                onChanged:       (_) => field.didChange(_emailController.text),
                onSubmitted:     (_) => _passFocus.requestFocus(),
                leading: const Icon(Icons.email_outlined, size: 20),
                semanticLabel: l.authEmail,
              ),
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
                obscure:         _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                textInputAction: TextInputAction.done,
                autofillHints:   const [AutofillHints.password],
                errorText:       field.errorText,
                onSubmitted:     (_) => _submit(),
              ),
            ),
            const SizedBox(height: 8),

            // ── Forgot password ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.goNamed(AppRoutes.forgotPassword),
                child: Text(
                  l.authForgotPassword,
                  style: tt.labelMedium?.copyWith(color: cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ───────────────────────────────────────────────────
            AppButton(
              label:     l.authLogin,
              size:      AppButtonSize.large,
              fullWidth: true,
              loading:   _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 32),

            AuthTextLink(
              prefix: l.authNoAccount,
              label:  l.authSignUp,
              onTap:  () => context.goNamed(AppRoutes.signup),
            ),
            const SizedBox(height: 24),

            AuthLegalText(l: l),
          ],
        ),
      ),
    );
  }
}
