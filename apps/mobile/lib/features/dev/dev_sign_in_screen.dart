import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';

/// Development builds only: signs in against the real API with an existing account (for example the seeded
/// demo accounts). It is the way to reach the app shell until the real sign-in forms ship in P1-M1.
class DevSignInScreen extends ConsumerStatefulWidget {
  const DevSignInScreen({super.key});

  @override
  ConsumerState<DevSignInScreen> createState() => _DevSignInScreenState();
}

class _DevSignInScreenState extends ConsumerState<DevSignInScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .signIn(identifier: _identifier.text, password: _password.text);
      // The router redirects away once the session changes.
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(onBack: () => context.pop(), title: l10n.devSignInTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AtSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.devSignInBody,
                      style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
                    ),
                    const SizedBox(height: 20),
                    AtTextField(
                      label: l10n.emailOrPhone,
                      controller: _identifier,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: 16),
                    AtPasswordField(
                      label: l10n.passwordLabel,
                      controller: _password,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _busy ? null : _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AtColors.pinkBg,
                            borderRadius: AtRadii.tileLg,
                          ),
                          child: Text(
                            _error!,
                            style: AtTextStyles.bodySm.copyWith(
                              color: AtColors.pinkStrong,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AtButton(
                      label: l10n.signInAction,
                      loading: _busy,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
