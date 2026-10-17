import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/identifier.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import 'auth_widgets.dart';
import 'verify_screen.dart';

final _hasDigit = RegExp(r'\d');

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _consent = false;
  bool _busy = false;
  bool _accountExists = false;
  String? _nameError;
  String? _identifierError;
  String? _passwordError;
  String? _consentError;
  String? _bannerError;

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Checks the form on the device first, so the common mistakes never cost a request.
  bool _validate(AppLocalizations l10n) {
    final nameOk = _name.text.trim().length >= 2;
    final idOk = parseIdentifier(_identifier.text).isValid;
    final pw = _password.text;
    final pwOk = pw.length >= 8 && _hasDigit.hasMatch(pw);
    setState(() {
      _nameError = nameOk ? null : l10n.fullNameError;
      _identifierError = idOk ? null : l10n.identifierError;
      _passwordError = pwOk ? null : l10n.passwordRuleError;
      _consentError = _consent ? null : l10n.consentRequired;
      _accountExists = false;
      _bannerError = null;
    });
    return nameOk && idOk && pwOk && _consent;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_validate(l10n)) return;
    final id = parseIdentifier(_identifier.text);
    setState(() => _busy = true);
    try {
      final ticket = await ref
          .read(sessionControllerProvider.notifier)
          .register(
            fullName: _name.text,
            identifier: id.value,
            password: _password.text,
          );
      if (!mounted) return;
      context.go(
        verifyLocation(
          identifier: id.value,
          resendAt: ticket.resendAvailableAt,
        ),
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _nameError = e.fieldError('fullName');
        _identifierError = e.fieldError('identifier');
        _passwordError = e.fieldError('password');
        _consentError = e.fieldError('consent');
        _accountExists = e.reason == 'ACCOUNT_EXISTS';
        if (_accountExists) _identifierError = e.message;
        final mapped =
            _nameError ?? _identifierError ?? _passwordError ?? _consentError;
        _bannerError = mapped == null ? e.message : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _bannerError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final google = ref.watch(googleSignInEnabledProvider).value ?? false;
    final id = parseIdentifier(_identifier.text);

    return AuthFormPage(
      title: l10n.signupTitle,
      subtitle: l10n.signupSubtitle,
      children: [
        AtTextField(
          label: l10n.fullNameLabel,
          controller: _name,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: 16),
        AtTextField(
          label: l10n.emailOrPhone,
          controller: _identifier,
          errorText: _identifierError,
          helperText: id.kind == IdentifierKind.invalid && _looksLikePhone()
              ? l10n.identifierHintPhone
              : null,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onChanged: (_) => setState(() {
            _identifierError = null;
            _accountExists = false;
          }),
        ),
        if (_accountExists)
          Align(
            alignment: Alignment.centerLeft,
            child: AtButton(
              label: l10n.signInInstead,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () => context.pushReplacement(Routes.signin),
            ),
          ),
        const SizedBox(height: 16),
        AtPasswordField(
          label: l10n.passwordLabel,
          controller: _password,
          errorText: _passwordError,
          showStrength: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() => _passwordError = null),
        ),
        const SizedBox(height: 18),
        AtCheckbox(
          value: _consent,
          onChanged: (v) => setState(() {
            _consent = v;
            _consentError = null;
          }),
          labelWidget: Text.rich(
            TextSpan(
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
              children: [
                TextSpan(text: l10n.consentPrefix),
                _link(
                  l10n.consentTermsLink,
                  () => context.push(Routes.legalPath('TERMS')),
                ),
                TextSpan(text: l10n.consentAnd),
                _link(
                  l10n.consentPrivacyLink,
                  () => context.push(Routes.legalPath('PRIVACY')),
                ),
              ],
            ),
          ),
        ),
        if (_consentError != null) ...[
          const SizedBox(height: 6),
          Text(
            _consentError!,
            style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
          ),
        ],
        if (_bannerError != null) ...[
          const SizedBox(height: 16),
          AtInlineBanner(message: _bannerError!),
        ],
        const SizedBox(height: 22),
        AtButton(
          label: l10n.signupAction,
          loading: _busy,
          onPressed: _busy ? null : _submit,
        ),
        if (google) ...[
          const SizedBox(height: 4),
          AtButton(
            label: l10n.googleContinue,
            variant: AtButtonVariant.secondary,
            // The Google SDK and OAuth credentials are an owner decision (Master Prompt section 12). With the
            // flag on but no SDK wired, the button says so instead of doing nothing.
            onPressed: () => context.push(
              Routes.soonPath('later', name: l10n.googleContinue),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.alreadyMember,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
            ),
            AtButton(
              label: l10n.welcomeSignIn,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () => context.pushReplacement(Routes.signin),
            ),
          ],
        ),
      ],
    );
  }

  bool _looksLikePhone() {
    final t = _identifier.text.trim();
    return t.isNotEmpty &&
        !t.contains('@') &&
        RegExp(r'^[\d+\s().-]+$').hasMatch(t);
  }

  InlineSpan _link(String text, VoidCallback onTap) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AtTextStyles.bodySm.copyWith(
          color: AtColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
