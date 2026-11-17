import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../community/community_common.dart' show relativeTime;
import '../community/community_providers.dart';
import '../discover/discover_common.dart';

/// Security: change password, two-step verification, and the devices signed in to the account.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _togglingTwoStep = false;
  final Set<String> _revoking = {};

  Future<void> _toggleTwoStep(SecurityDto s, bool on) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _togglingTwoStep = true);
    try {
      await ref.read(accountRepositoryProvider).setTwoStep(on);
      ref.invalidate(securityProvider);
      await ref.read(securityProvider.future);
      if (mounted) {
        showNotice(context, on ? l10n.stTwoStepOn : l10n.stTwoStepOff);
      }
    } on Object catch (e) {
      if (mounted) showNotice(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _togglingTwoStep = false);
    }
  }

  Future<void> _revoke(SessionViewDto s) async {
    setState(() => _revoking.add(s.id));
    try {
      await ref.read(accountRepositoryProvider).revokeSession(s.id);
      ref.invalidate(sessionsProvider);
      ref.invalidate(securityProvider);
    } on Object catch (e) {
      if (mounted) showNotice(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _revoking.remove(s.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final security = ref.watch(securityProvider);
    final sessions = ref.watch(sessionsProvider);
    final now = ref.watch(communityClockProvider)();
    return SubPage(
      title: l10n.settingsSecurity,
      child: security.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(securityProvider), l10n),
        data: (s) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            8,
            AtSpacing.gutter,
            32,
          ),
          children: [
            AtCard(
              onTap: () => showAtBottomSheet<void>(
                context: context,
                title: l10n.stChangePassword,
                builder: (_) => const _ChangePasswordSheet(),
              ),
              child: Row(
                children: [
                  const AtIconTile(
                    icon: LucideIcons.keyRound,
                    tone: AtTone.indigo,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.stPassword,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                  Text(
                    l10n.stChange,
                    style: AtTextStyles.buttonSm.copyWith(
                      color: context.at.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtSpacing.listGap),
            AtCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AtIconTile(
                        icon: LucideIcons.shieldCheck,
                        tone: AtTone.violet,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.stTwoStep,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: context.at.ink,
                              ),
                            ),
                            Text(
                              l10n.stTwoStepBody,
                              style: AtTextStyles.metaSm.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AtToggle(
                        value: s.twoStepEnabled,
                        semanticLabel: l10n.stTwoStep,
                        onChanged: _togglingTwoStep
                            ? null
                            : (v) => _toggleTwoStep(s, v),
                      ),
                    ],
                  ),
                  if (!s.hasVerifiedFactor && !s.twoStepEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        l10n.stTwoStepNeedsPhone,
                        style: AtTextStyles.metaSm.copyWith(
                          color: context.at.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GroupLabel(l10n.stActiveSessions),
            sessions.when(
              loading: () => const AtSkeleton(height: 70, radius: 16),
              error: (e, _) => AtInlineBanner(
                message: failureMessage(e),
                tone: AtBannerTone.error,
              ),
              data: (list) => Column(
                children: [
                  for (final x in list) ...[
                    AtCard(
                      child: Row(
                        children: [
                          AtIconTile(
                            icon: switch (x.client) {
                              SessionViewDtoClient.web => LucideIcons.globe,
                              _ => LucideIcons.smartphone,
                            },
                            tone: x.current ? AtTone.success : AtTone.neutral,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  x.deviceName ?? l10n.stUnknownDevice,
                                  style: AtTextStyles.cardTitle.copyWith(
                                    color: context.at.ink,
                                  ),
                                ),
                                Text(
                                  [
                                    if (x.current) l10n.stThisDevice,
                                    if (x.approxLocation != null)
                                      x.approxLocation!,
                                    relativeTime(l10n, x.lastActiveAt, now),
                                  ].join(' · '),
                                  style: AtTextStyles.metaSm.copyWith(
                                    color: context.at.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!x.current)
                            AtButton(
                              label: l10n.stSignOutSession,
                              variant: AtButtonVariant.tertiary,
                              size: AtButtonSize.sm,
                              fullWidth: false,
                              loading: _revoking.contains(x.id),
                              onPressed: () => _revoke(x),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AtSpacing.listGap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Current password, then a new one. Other devices are signed out when it changes.
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .changePassword(_current.text, _next.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      showNotice(context, l10n.stPasswordChanged);
    } on Object catch (e) {
      setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtPasswordField(
            label: l10n.stCurrentPassword,
            controller: _current,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AtPasswordField(
            label: l10n.stNewPassword,
            controller: _next,
            showStrength: true,
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          ],
          const SizedBox(height: 18),
          AtButton(
            label: l10n.stChangePassword,
            loading: _busy,
            onPressed: _current.text.isEmpty || _next.text.length < 8 || _busy
                ? null
                : _save,
          ),
        ],
      ),
    );
  }
}
