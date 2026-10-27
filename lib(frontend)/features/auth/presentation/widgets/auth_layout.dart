import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../shared/widgets/app_text_field.dart';

// ── AuthLayout ────────────────────────────────────────────────────────────────

/// Shared scroll + padding wrapper used by every auth screen.
///
/// Handles keyboard avoidance, safe-area insets, and centres content
/// on wide screens (tablet / landscape) without each screen repeating the
/// boilerplate.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool   resizeToAvoidBottomInset;

  /// Max content width — prevents stretched forms on wide screens.
  static const double maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ── AuthBrand ─────────────────────────────────────────────────────────────────

/// Header icon + headline + sub-headline used at the top of every auth screen.
class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, required this.headline, required this.subhead});
  final String headline;
  final String subhead;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  64,
          height: 64,
          decoration: BoxDecoration(
            color:        cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.agriculture_rounded, size: 36, color: cs.primary),
        ),
        const SizedBox(height: 24),
        Text(headline, style: tt.headlineMedium),
        const SizedBox(height: 4),
        Text(
          subhead,
          style: tt.titleMedium
              ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── AuthPasswordField ─────────────────────────────────────────────────────────

/// Password field with show / hide toggle.
/// Reused by login, signup, and reset-password screens.
class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggleObscure,
    this.textInputAction = TextInputAction.done,
    this.autofillHints,
    this.onSubmitted,
    this.errorText,
  });

  final TextEditingController  controller;
  final FocusNode              focusNode;
  final String                 label;
  final String                 hint;
  final bool                   obscure;
  final VoidCallback           onToggleObscure;
  final TextInputAction        textInputAction;
  final Iterable<String>?      autofillHints;
  final ValueChanged<String>?  onSubmitted;
  final String?                errorText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppTextField(
      controller:      controller,
      focusNode:       focusNode,
      label:           label,
      hint:            hint,
      obscureText:     obscure,
      keyboardType:    TextInputType.visiblePassword,
      textInputAction: textInputAction,
      autofillHints:   autofillHints,
      onSubmitted:     onSubmitted,
      errorText:       errorText,
      semanticLabel:   label,
      leading: const Icon(Icons.lock_outline_rounded, size: 20),
      trailing: IconButton(
        tooltip:  obscure ? l.authShowPassword : l.authHidePassword,
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
        ),
        onPressed: onToggleObscure,
      ),
    );
  }
}

// ── AuthTextLink ──────────────────────────────────────────────────────────────

/// A RichText inline link — e.g. "Don't have an account? Sign Up".
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.prefix,
    required this.label,
    required this.onTap,
  });

  final String       prefix;
  final String       label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall;
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: style,
          children: [
            TextSpan(
              text:  prefix,
              style: style?.copyWith(color: cs.onSurfaceVariant),
            ),
            TextSpan(
              text:  label,
              style: style?.copyWith(
                color:      cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AuthErrorBanner ───────────────────────────────────────────────────────────

/// Inline error banner shown below a form when an auth operation fails.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        cs.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size:  18,
              color: cs.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AuthLegalText ─────────────────────────────────────────────────────────────

/// "By continuing you agree to our Terms of Service and Privacy Policy."
class AuthLegalText extends StatelessWidget {
  const AuthLegalText({super.key, required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: cs.onSurfaceVariant);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: l.authAgreeToTerms),
          TextSpan(
            text:  l.authTermsOfService,
            style: style?.copyWith(
              color:      cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: l.authPrivacyPolicy),
        ],
      ),
    );
  }
}
