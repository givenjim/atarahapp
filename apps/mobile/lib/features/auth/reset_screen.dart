import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/notices/app_notice.dart';
import '../../core/routing/routes.dart';
import 'auth_widgets.dart';

final _hasDigit = RegExp(r'\d');

/// Step two of recovery: the emailed or texted code plus the new password. On success the member is signed in,
/// and told that their other devices were signed out.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, required this.identifier, this.codeJustSent});

  final String identifier;

  /// Show "Code sent. It expires in 15 minutes." (the member just asked for a code).
  final bool? codeJustSent;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final codeOk = _code.text.length == 6;
    final pw = _password.text;
    final pwOk = pw.length >= 8 && _hasDigit.hasMatch(pw);
    final matches = pw == _confirm.text;
    setState(() {
      _codeError = codeOk ? null : l10n.codeIncomplete;
      _passwordError = pwOk ? null : l10n.passwordRuleError;
      _confirmError = matches ? null : l10n.passwordsDontMatch;
      _error = null;
    });
    if (!codeOk || !pwOk || !matches) return;

    // Captured now: the router leaves this screen as soon as sign-in completes.
    final notice = ref.read(appNoticeProvider.notifier);
    final message = l10n.resetDone;
    setState(() => _busy = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .resetPasswordAndSignIn(
            identifier: widget.identifier,
            code: _code.text,
            newPassword: pw,
          );
      notice.show(message);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _codeError = e.fieldError('code');
        _passwordError = e.fieldError('newPassword');
        _error = _codeError == null && _passwordError == null
            ? e.message
            : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFormPage(
      title: l10n.resetTitle,
      subtitle: l10n.resetBody,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.signin),
      children: [
        if (widget.codeJustSent ?? false) ...[
          AtInlineBanner(message: l10n.forgotSent, tone: AtBannerTone.success),
          const SizedBox(height: 18),
        ],
        Text(
          l10n.recoveryCodeLabel,
          style: AtTextStyles.chip.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 8),
        AtCodeInput(
          controller: _code,
          autofocus: true,
          hasError: _codeError != null,
          onChanged: (_) => setState(() => _codeError = null),
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 6),
          Text(
            _codeError!,
            style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
          ),
        ],
        const SizedBox(height: 18),
        AtPasswordField(
          label: l10n.newPasswordLabel,
          controller: _password,
          errorText: _passwordError,
          showStrength: true,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _passwordError = null),
        ),
        const SizedBox(height: 16),
        AtPasswordField(
          label: l10n.confirmPasswordLabel,
          controller: _confirm,
          errorText: _confirmError,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() => _confirmError = null),
          onSubmitted: (_) => _busy ? null : _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          AtInlineBanner(message: _error!),
        ],
        const SizedBox(height: 22),
        AtButton(
          label: l10n.resetAction,
          loading: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}
