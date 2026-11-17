import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/session_controller.dart';
import '../../core/auth/two_step.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';

/// The second step of sign-in. Reads Supabase MFA through [TwoStepVerifier] so tests (and a build without a phone
/// factor) can replace it.
final twoStepVerifierProvider = Provider<TwoStepVerifier>(
  (ref) => SupabaseTwoStepVerifier(ref.watch(supabaseClientProvider)),
);

/// "Enter the code we sent you": shown when the API says this device needs the second step. A correct code makes the
/// session AAL2, after which the app carries on where it was.
class TwoStepScreen extends ConsumerStatefulWidget {
  const TwoStepScreen({super.key});

  @override
  ConsumerState<TwoStepScreen> createState() => _TwoStepScreenState();
}

class _TwoStepScreenState extends ConsumerState<TwoStepScreen> {
  final _code = TextEditingController();
  TwoStepChallenge? _challenge;
  bool _starting = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final c = await ref.read(twoStepVerifierProvider).start();
      if (mounted) setState(() => _challenge = c);
    } on NoSecondFactorException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).stTwoStepNoFactor);
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _verify() async {
    final c = _challenge;
    if (c == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(twoStepVerifierProvider).complete(c, _code.text.trim());
      ref.read(twoStepRequiredProvider.notifier).clear();
      // Everything that failed with the 403 loads again with the upgraded session.
      ref.invalidate(sessionControllerProvider);
      if (mounted) context.go(Routes.home);
    } on Object {
      if (mounted) setState(() => _error = l10n.stTwoStepWrongCode);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = _challenge?.phone ?? true;
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.settings,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: AtIconTile(
                  icon: LucideIcons.shieldCheck,
                  tone: AtTone.violet,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  l10n.stTwoStepTitle,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.sectionTitle.copyWith(
                    color: context.at.ink,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                phone ? l10n.stTwoStepSms : l10n.stTwoStepApp,
                textAlign: TextAlign.center,
                style: AtTextStyles.body.copyWith(color: context.at.body),
              ),
              const SizedBox(height: 20),
              if (_starting)
                const AtSkeleton(height: 56, radius: 14)
              else if (_challenge != null)
                AtCodeInput(
                  controller: _code,
                  hasError: _error != null,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  onCompleted: (_) => _verify(),
                ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                AtInlineBanner(message: _error!, tone: AtBannerTone.error),
              ],
              const SizedBox(height: 22),
              if (_challenge != null)
                AtButton(
                  label: l10n.stVerify,
                  loading: _busy,
                  onPressed: _code.text.trim().length < 6 || _busy
                      ? null
                      : _verify,
                )
              else if (!_starting)
                AtButton(label: l10n.retry, onPressed: _start),
              const SizedBox(height: 10),
              AtButton(
                label: l10n.signOut,
                variant: AtButtonVariant.secondary,
                onPressed: () {
                  ref.read(twoStepRequiredProvider.notifier).clear();
                  ref.read(sessionControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
