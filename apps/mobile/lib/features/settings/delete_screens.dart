import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

/// Delete account: what will be lost, the word DELETE to confirm and the password to prove it is the member. The
/// account is hidden and signed out at once; the data is removed after 30 days, and signing in before then offers
/// "Restore account".
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  /// The button works only when the word is typed exactly.
  bool get _ready => _confirm.text.trim() == 'DELETE';

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .deleteAccount(
            confirm: _confirm.text.trim(),
            password: _password.text.isEmpty ? null : _password.text,
          );
      if (!mounted) return;
      // The spinner stops before the confirmation opens (a screen that never settles is not a finished one).
      setState(() => _busy = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: AtModalFrame(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.stDeletedTitle,
                  style: AtTextStyles.sectionTitleSm.copyWith(
                    color: ctx.at.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.stDeletedBody,
                  style: AtTextStyles.bodySm.copyWith(color: ctx.at.body),
                ),
                const SizedBox(height: 18),
                AtButton(
                  label: l10n.stOk,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      );
      await ref.read(sessionControllerProvider.notifier).signOut();
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final losses = [
      l10n.stDeleteLossProfile,
      l10n.stDeleteLossPortfolio,
      l10n.stDeleteLossConnections,
      l10n.stDeleteLossProgress,
    ];
    return SubPage(
      title: l10n.stDeleteAccount,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          8,
          AtSpacing.gutter,
          32,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.stDeleteTitle,
              style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.stDeleteIntro,
            style: AtTextStyles.bodySm.copyWith(color: context.at.body),
          ),
          const SizedBox(height: 12),
          for (final t in losses)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.circleX,
                    size: 16,
                    color: context.at.coralStrong,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t,
                      style: AtTextStyles.bodySm.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            l10n.stDeleteGrace,
            style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
          ),
          const SizedBox(height: 18),
          AtTextField(
            label: l10n.stTypeDelete,
            controller: _confirm,
            hint: 'DELETE',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AtPasswordField(
            label: l10n.stPasswordToConfirm,
            controller: _password,
            onChanged: (_) => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.stPasswordToConfirmHelp,
              style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          ],
          const SizedBox(height: 22),
          AtButton(
            label: l10n.stDeletePermanently,
            variant: AtButtonVariant.destructive,
            loading: _busy,
            onPressed: _ready && !_busy ? _delete : null,
          ),
          const SizedBox(height: 10),
          AtButton(
            label: l10n.stKeepAccount,
            variant: AtButtonVariant.secondary,
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.settings),
          ),
        ],
      ),
    );
  }
}

/// A member whose account is scheduled for deletion signs in and lands here instead of Home: restore it, or sign out.
class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _restore() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountRepositoryProvider).restore();
      // Reload the member: the account is active again, so the router lets them through.
      ref.invalidate(sessionControllerProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).value;
    final date = user?.deletionScheduledFor;
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
                  icon: LucideIcons.archiveRestore,
                  tone: AtTone.amber,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  l10n.stRestoreTitle,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.sectionTitle.copyWith(
                    color: context.at.ink,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                date == null
                    ? l10n.stRestoreBodyNoDate
                    : l10n.stRestoreBody(shortDate(context, date.toLocal())),
                textAlign: TextAlign.center,
                style: AtTextStyles.body.copyWith(color: context.at.body),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                AtInlineBanner(message: _error!, tone: AtBannerTone.error),
              ],
              const SizedBox(height: 24),
              AtButton(
                label: l10n.stRestoreAccount,
                loading: _busy,
                onPressed: _busy ? null : _restore,
              ),
              const SizedBox(height: 10),
              AtButton(
                label: l10n.signOut,
                variant: AtButtonVariant.secondary,
                onPressed: _busy
                    ? null
                    : () => ref
                          .read(sessionControllerProvider.notifier)
                          .signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
