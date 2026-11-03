import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/auth_state.dart';
import '../auth_providers.dart';
import 'widgets/auth_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus      = FocusNode();
  bool  _isSubmitting    = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.authFieldRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return l.authInvalidEmail;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    // Clear any previous auth error before the operation.
    ref.read(authNotifierProvider.notifier).clearError();

    final email = _emailController.text.trim();
    await ref.read(authNotifierProvider.notifier).forgotPassword(email);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Only navigate when state does NOT contain an error.
    final state = ref.read(authNotifierProvider);
    if (state is! AuthStateError) {
      context.goNamed(
        AppRoutes.verifyOtp,
        queryParameters: {'email': email, 'mode': 'reset'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
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
            // ── Back button ──────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip:  l.cancel,
                icon:     const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            const SizedBox(height: 8),

            // ── Header ───────────────────────────────────────────────────
            Container(
              width:  56,
              height: 56,
              decoration: BoxDecoration(
                color:        cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.lock_reset_rounded, size: 28, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(l.authForgotPasswordTitle, style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l.authForgotPasswordBody,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // ── Error banner ─────────────────────────────────────────────
            if (errorMessage != null) ...[
              AuthErrorBanner(message: errorMessage),
              const SizedBox(height: 16),
            ],

            // ── Email field ──────────────────────────────────────────────
            FormField<String>(
              validator: (_) => _validateEmail(_emailController.text, l),
              builder: (field) => AppTextField(
                controller:      _emailController,
                focusNode:       _emailFocus,
                label:           l.authEmail,
                hint:            l.authEmailHint,
                keyboardType:    TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints:   const [AutofillHints.email],
                errorText:       field.errorText,
                onChanged:       (_) => field.didChange(_emailController.text),
                onSubmitted:     (_) => _submit(),
                leading:         const Icon(Icons.email_outlined, size: 20),
                semanticLabel:   l.authEmail,
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ───────────────────────────────────────────────────
            AppButton(
              label:     l.authSendOtp,
              size:      AppButtonSize.large,
              fullWidth: true,
              loading:   _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
              leading:   const Icon(Icons.send_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
