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

/// Step one of recovery: ask for a code. The next screen takes the code and the new password.
class ForgotScreen extends ConsumerStatefulWidget {
  const ForgotScreen({super.key, this.identifier});

  /// Pre-filled from the sign-in screen when the member had already typed it.
  final String? identifier;

  @override
  ConsumerState<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends ConsumerState<ForgotScreen> {
  late final _identifier = TextEditingController(text: widget.identifier);
  bool _busy = false;
  String? _fieldError;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final id = parseIdentifier(_identifier.text);
    if (!id.isValid) {
      setState(() => _fieldError = l10n.identifierError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _fieldError = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .requestPasswordReset(id.value);
      if (!mounted) return;
      context.pushReplacement(
        Uri(
          path: Routes.reset,
          queryParameters: {'identifier': id.value, 'sent': '1'},
        ).toString(),
      );
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _fieldError = e is ApiFailure ? e.fieldError('identifier') : null;
        _error = _fieldError == null ? e.message : null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFormPage(
      title: l10n.forgotTitle,
      subtitle: l10n.forgotBody,
      children: [
        AtTextField(
          label: l10n.emailOrPhone,
          controller: _identifier,
          errorText: _fieldError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.username],
          onChanged: (_) => setState(() => _fieldError = null),
          onSubmitted: (_) => _busy ? null : _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          AtInlineBanner(message: _error!),
        ],
        const SizedBox(height: 22),
        AtButton(
          label: l10n.forgotAction,
          loading: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}
