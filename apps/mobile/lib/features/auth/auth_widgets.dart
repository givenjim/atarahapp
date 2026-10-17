import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';

/// Page frame shared by the form screens: back button, scrolling body, the standard gutter.
class AuthFormPage extends StatelessWidget {
  const AuthFormPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              onBack:
                  onBack ??
                  () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.welcome),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  8,
                  AtSpacing.gutter,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: AtTextStyles.body.copyWith(color: AtColors.body),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ...children,
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

/// `0:42`, `1:05`.
String formatCountdown(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// "Resend in 0:42" that turns into a "Resend code" button when the server cooldown ends. The remaining time
/// comes from the server's `resendAvailableAt`, so the app never invents its own cooldown.
class ResendCountdown extends StatefulWidget {
  const ResendCountdown({
    super.key,
    required this.availableAt,
    required this.onResend,
    this.busy = false,
  });

  final DateTime? availableAt;
  final Future<void> Function() onResend;
  final bool busy;

  @override
  State<ResendCountdown> createState() => _ResendCountdownState();
}

class _ResendCountdownState extends State<ResendCountdown> {
  Timer? _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(ResendCountdown old) {
    super.didUpdateWidget(old);
    if (old.availableAt != widget.availableAt) _reset();
  }

  void _reset() {
    _timer?.cancel();
    final at = widget.availableAt;
    _remaining = at == null
        ? 0
        : at.difference(DateTime.now()).inSeconds.clamp(0, 3600);
    if (_remaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _remaining--);
        if (_remaining <= 0) t.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.verifyDidntGet,
          style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
        ),
        const SizedBox(width: 8),
        if (_remaining > 0)
          Semantics(
            liveRegion: false,
            child: Text(
              l10n.verifyResendIn(formatCountdown(_remaining)),
              style: AtTextStyles.chip.copyWith(color: AtColors.muted),
            ),
          )
        else
          AtButton(
            label: l10n.verifyResend,
            variant: AtButtonVariant.tertiary,
            size: AtButtonSize.sm,
            fullWidth: false,
            loading: widget.busy,
            onPressed: widget.busy ? null : () => widget.onResend(),
          ),
      ],
    );
  }
}

/// The message to show for a failed request: the server's own words for API errors, a generic line otherwise.
String failureMessage(Object error) =>
    error is AppFailure ? error.message : const UnexpectedFailure().message;
