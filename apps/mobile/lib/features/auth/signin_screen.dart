import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/identifier.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import 'auth_widgets.dart';
import 'verify_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _identifierError;
  String? _error;
  bool _locked = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final id = parseIdentifier(_identifier.text);
    if (!id.isValid) {
      setState(() => _identifierError = l10n.identifierError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _locked = false;
      _identifierError = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .signIn(identifier: id.value, password: _password.text);
      // The router redirects away once the session changes.
    } on ApiFailure catch (e) {
      if (!mounted) return;
      if (e.reason == 'ACCOUNT_NOT_VERIFIED') {
        // Right password, account not verified yet: the API has sent a fresh code.
        context.go(
          verifyLocation(
            identifier: id.value,
            resendAt: DateTime.now().add(const Duration(seconds: 60)),
          ),
        );
        return;
      }
      setState(() {
        _error = e.message;
        _locked = e.reason == 'SIGN_IN_LOCKED';
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
      title: l10n.signInTitle,
      subtitle: l10n.signInSubtitle,
      children: [
        AtTextField(
          label: l10n.emailOrPhone,
          controller: _identifier,
          errorText: _identifierError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onChanged: (_) => setState(() => _identifierError = null),
        ),
        const SizedBox(height: 16),
        AtPasswordField(
          label: l10n.passwordLabel,
          controller: _password,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _busy ? null : _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AtButton(
            label: l10n.forgotPasswordLink,
            variant: AtButtonVariant.tertiary,
            size: AtButtonSize.sm,
            fullWidth: false,
            onPressed: () => context.push(
              Uri(
                path: Routes.forgot,
                queryParameters: {
                  if (parseIdentifier(_identifier.text).isValid)
                    'identifier': parseIdentifier(_identifier.text).value,
                },
              ).toString(),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          AtInlineBanner(
            message: _locked ? '$_error ${l10n.signInLockedHint}' : _error!,
          ),
        ],
        const SizedBox(height: 20),
        AtButton(
          label: l10n.signInAction,
          loading: _busy,
          onPressed: _busy ? null : _submit,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.newToAtarah,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
            ),
            AtButton(
              label: l10n.createAnAccount,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () => context.pushReplacement(Routes.signup),
            ),
          ],
        ),
      ],
    );
  }
}
