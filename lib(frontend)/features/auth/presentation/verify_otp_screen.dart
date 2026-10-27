import 'dart:async';

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

/// Two-step password-reset flow:
///   Step 1 — Enter the 6-digit OTP sent to [email].
///   Step 2 — Enter and confirm the new password.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.mode = 'reset',
  });

  final String email;
  final String mode;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  // ── Step tracking ──────────────────────────────────────────────────────────
  _OtpStep _step = _OtpStep.enterOtp;

  // ── OTP step state ────────────────────────────────────────────────────────
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // ── New-password step state ───────────────────────────────────────────────
  final _resetFormKey       = GlobalKey<FormState>();
  final _newPassController  = TextEditingController();
  final _confPassController = TextEditingController();
  final _newPassFocus       = FocusNode();
  final _confPassFocus      = FocusNode();
  bool  _obscureNew         = true;
  bool  _obscureConf        = true;

  // ── Shared ────────────────────────────────────────────────────────────────
  bool   _isSubmitting  = false;
  Timer? _resendTimer;
  int    _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes)  f.dispose();
    _newPassController.dispose();
    _confPassController.dispose();
    _newPassFocus.dispose();
    _confPassFocus.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
        else t.cancel();
      });
    });
  }

  // ── OTP helpers ───────────────────────────────────────────────────────────

  String get _otpValue => _otpControllers.map((c) => c.text).join();
  bool   get _otpComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    // Handle paste — spread digits across boxes.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').characters.toList();
      for (int i = 0; i < digits.length && i + index < 6; i++) {
        _otpControllers[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, 5);
      _otpFocusNodes[next].requestFocus();
    } else if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      _otpControllers[index - 1].clear();
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  // ── Submit: verify OTP ────────────────────────────────────────────────────

  Future<void> _submitOtp() async {
    if (!_otpComplete || _isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final ok = await ref.read(authNotifierProvider.notifier).verifyOtp(
      email: widget.email,
      otp:   _otpValue,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) setState(() => _step = _OtpStep.newPassword);
  }

  // ── Submit: reset password ────────────────────────────────────────────────

  Future<void> _submitReset() async {
    if (!_resetFormKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final ok = await ref.read(authNotifierProvider.notifier).resetPassword(
      email:       widget.email,
      otp:         _otpValue,
      newPassword: _newPassController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      final l = AppLocalizations.of(context);
      context.goNamed(AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.authResetPassword)),
      );
    }
  }

  // ── Resend ────────────────────────────────────────────────────────────────

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    await ref.read(authNotifierProvider.notifier).forgotPassword(widget.email);
    _startResendTimer();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => switch (_step) {
    _OtpStep.enterOtp   => _buildOtpStep(context),
    _OtpStep.newPassword => _buildNewPasswordStep(context),
  };

  // ── Step 1: OTP entry ─────────────────────────────────────────────────────

  Widget _buildOtpStep(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final state = ref.watch(authNotifierProvider);
    final String? err = switch (state) {
      AuthStateError(:final failure) => failure.message,
      _                              => null,
    };

    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip:   l.cancel,
              icon:      const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(height: 8),
          _HeaderIcon(icon: Icons.mark_email_read_outlined, color: cs.primary, bg: cs.primaryContainer),
          const SizedBox(height: 20),
          Text(l.authOtpTitle, style: tt.headlineSmall),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              children: [
                TextSpan(text: '${l.authOtpBody} '),
                TextSpan(
                  text:  widget.email,
                  style: tt.bodyMedium?.copyWith(
                    color:      cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (err != null) ...[
            AuthErrorBanner(message: err),
            const SizedBox(height: 16),
          ],
          // Six digit boxes
          Semantics(
            label: l.authOtpHint,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _OtpBox(
                controller:  _otpControllers[i],
                focusNode:   _otpFocusNodes[i],
                onChanged:   (v) => _onDigitChanged(i, v),
                onBackspace: () => _onBackspace(i),
                hasError:    err != null,
              )),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: _resendSeconds > 0
                ? Text(
                    '${l.authResendOtpIn} ${_resendSeconds}s',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  )
                : TextButton(
                    onPressed: _resendOtp,
                    child:     Text(l.authResendOtp),
                  ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label:     l.authVerify,
            size:      AppButtonSize.large,
            fullWidth: true,
            loading:   _isSubmitting,
            onPressed: (_otpComplete && !_isSubmitting) ? _submitOtp : null,
          ),
        ],
      ),
    );
  }

  // ── Step 2: New password ──────────────────────────────────────────────────

  Widget _buildNewPasswordStep(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final state = ref.watch(authNotifierProvider);
    final String? err = switch (state) {
      AuthStateError(:final failure) => failure.message,
      _                              => null,
    };

    return AuthLayout(
      child: Form(
        key: _resetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderIcon(
              icon:  Icons.lock_outline_rounded,
              color: cs.primary,
              bg:    cs.primaryContainer,
            ),
            const SizedBox(height: 20),
            Text(l.authResetPasswordTitle, style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l.authNewPasswordHint,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            if (err != null) ...[
              AuthErrorBanner(message: err),
              const SizedBox(height: 16),
            ],
            FormField<String>(
              validator: (_) {
                final v = _newPassController.text;
                if (v.isEmpty) return l.authFieldRequired;
                if (v.length < 8) return l.authPasswordTooShort;
                return null;
              },
              builder: (field) => AuthPasswordField(
                controller:      _newPassController,
                focusNode:       _newPassFocus,
                label:           l.authNewPassword,
                hint:            l.authNewPasswordHint,
                obscure:         _obscureNew,
                onToggleObscure: () =>
                    setState(() => _obscureNew = !_obscureNew),
                textInputAction: TextInputAction.next,
                autofillHints:   const [AutofillHints.newPassword],
                errorText:       field.errorText,
                onSubmitted:     (_) => _confPassFocus.requestFocus(),
              ),
            ),
            const SizedBox(height: 16),
            FormField<String>(
              validator: (_) {
                final v = _confPassController.text;
                if (v.isEmpty) return l.authFieldRequired;
                if (v != _newPassController.text) return l.authPasswordsDoNotMatch;
                return null;
              },
              builder: (field) => AuthPasswordField(
                controller:      _confPassController,
                focusNode:       _confPassFocus,
                label:           l.authConfirmPassword,
                hint:            l.authConfirmPasswordHint,
                obscure:         _obscureConf,
                onToggleObscure: () =>
                    setState(() => _obscureConf = !_obscureConf),
                textInputAction: TextInputAction.done,
                autofillHints:   const [AutofillHints.newPassword],
                errorText:       field.errorText,
                onSubmitted:     (_) => _submitReset(),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label:     l.authResetPassword,
              size:      AppButtonSize.large,
              fullWidth: true,
              loading:   _isSubmitting,
              onPressed: _isSubmitting ? null : _submitReset,
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP digit box ─────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onBackspace;
  final bool                  hasError;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width:  44,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller:      controller,
          focusNode:       focusNode,
          keyboardType:    TextInputType.number,
          textAlign:       TextAlign.center,
          maxLength:       1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged:       onChanged,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            counterText:  '',
            filled:       true,
            fillColor:    hasError
                ? cs.errorContainer
                : cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(color: hasError ? cs.error : cs.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(
                color: hasError ? cs.error : cs.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(color: hasError ? cs.error : cs.outline),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared header icon ────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.color,
    required this.bg,
  });
  final IconData icon;
  final Color    color;
  final Color    bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  56,
      height: 56,
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child:     Icon(icon, size: 28, color: color),
    );
  }
}

// ── Step enum ─────────────────────────────────────────────────────────────────

enum _OtpStep { enterOtp, newPassword }
