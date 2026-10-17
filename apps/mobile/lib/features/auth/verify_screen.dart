import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/identifier.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import 'auth_widgets.dart';

/// `/verify?identifier=…&resendAt=<epoch ms>&from=/onboarding`. A new member continues into onboarding; the
/// router honours `from` once the code signs them in.
String verifyLocation({required String identifier, DateTime? resendAt}) {
  final q = <String, String>{
    'identifier': identifier,
    'from': Routes.onboarding,
    if (resendAt != null)
      'resendAt': resendAt.millisecondsSinceEpoch.toString(),
  };
  return Uri(path: Routes.verify, queryParameters: q).toString();
}

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.identifier, this.resendAt});

  final String identifier;
  final DateTime? resendAt;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _code = TextEditingController();
  late DateTime? _resendAt = widget.resendAt;
  bool _busy = false;
  bool _resending = false;
  bool _showResent = false;
  String? _error;

  bool get _complete => _code.text.length == 6;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_complete || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _showResent = false;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .verify(identifier: widget.identifier, code: _code.text);
      // Signed in: the router leaves this screen.
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final next = await ref
          .read(sessionControllerProvider.notifier)
          .resendCode(widget.identifier);
      if (!mounted) return;
      setState(() {
        _resendAt = next ?? DateTime.now().add(const Duration(seconds: 60));
        _showResent = true;
        _code.clear();
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = parseIdentifier(widget.identifier).kind;

    return AuthFormPage(
      title: kind == IdentifierKind.phone
          ? l10n.verifyTitlePhone
          : l10n.verifyTitleEmail,
      subtitle: l10n.verifyBody,
      children: [
        Text(
          widget.identifier,
          style: AtTextStyles.sectionTitle.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 20),
        Semantics(
          label: l10n.verifyCodeLabel,
          child: AtCodeInput(
            controller: _code,
            autofocus: true,
            hasError: _error != null,
            onChanged: (_) => setState(() => _error = null),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          AtInlineBanner(message: _error!),
        ],
        if (_showResent && _error == null) ...[
          const SizedBox(height: 14),
          AtInlineBanner(
            message: l10n.verifyResent,
            tone: AtBannerTone.success,
          ),
        ],
        const SizedBox(height: 22),
        AtButton(
          label: l10n.verifyAction,
          loading: _busy,
          onPressed: _complete && !_busy ? _verify : null,
        ),
        const SizedBox(height: 8),
        ResendCountdown(
          availableAt: _resendAt,
          busy: _resending,
          onResend: _resend,
        ),
        const SizedBox(height: 22),
        AtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: LucideIcons.shieldCheck,
                lead: l10n.verifyWhyLead,
                body: l10n.verifyWhyBody,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: LucideIcons.sparkles,
                lead: l10n.verifyNextLead,
                body: l10n.verifyNextBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.lead, required this.body});

  final IconData icon;
  final String lead;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AtColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
              children: [
                TextSpan(
                  text: lead,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AtColors.ink,
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
