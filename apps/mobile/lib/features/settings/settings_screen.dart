import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/appearance/appearance_controller.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';

/// Settings: Account, Privacy & visibility, Notifications, Membership, Security, Help, Legal, Log out and
/// Delete account. Appearance applies at once and follows the member's account.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(sessionControllerProvider.notifier).signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appearance = ref.watch(appearanceControllerProvider);
    final user = ref.watch(sessionControllerProvider).value;
    final isPro = user?.membership.plan.name.toLowerCase() == 'pro';

    Widget group(String label, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 6, 8),
          child: Semantics(
            header: true,
            child: Text(
              label,
              style: AtTextStyles.label.copyWith(color: context.at.muted),
            ),
          ),
        ),
        AtCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: rows),
        ),
      ],
    );

    return AtPage(
      wash: AtWash.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtTopBar(
            onBack: () =>
                context.canPop() ? context.pop() : context.go(Routes.profile),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                0,
                AtSpacing.gutter,
                AtSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.profileSettings,
                      style: AtTextStyles.tabTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                  group(l10n.settingsGroupAccount, [
                    AtListRow(
                      title: l10n.settingsAccount,
                      icon: LucideIcons.user,
                      tone: AtTone.indigo,
                      showDivider: true,
                      onTap: () => context.push(Routes.accountSettings),
                    ),
                    AtAppearanceToggle(
                      value: appearance,
                      showDivider: true,
                      onChanged: (v) => ref
                          .read(appearanceControllerProvider.notifier)
                          .set(v),
                    ),
                    AtListRow(
                      title: l10n.settingsPrivacy,
                      icon: LucideIcons.eye,
                      tone: AtTone.violet,
                      showDivider: true,
                      onTap: () => context.push(Routes.privacySettings),
                    ),
                    AtListRow(
                      title: l10n.settingsNotifications,
                      icon: LucideIcons.bell,
                      tone: AtTone.warning,
                      showDivider: true,
                      onTap: () => context.push(Routes.notificationSettings),
                    ),
                    AtListRow(
                      title: l10n.profileMembership,
                      icon: LucideIcons.crown,
                      tone: AtTone.amber,
                      trailing: AtTag(
                        label: isPro
                            ? l10n.profileMembershipPro
                            : l10n.profileMembershipFree,
                        tone: isPro ? AtTone.amber : AtTone.neutral,
                      ),
                      showDivider: true,
                      onTap: () => context.push(Routes.membership),
                    ),
                    AtListRow(
                      title: l10n.settingsSecurity,
                      icon: LucideIcons.shield,
                      tone: AtTone.indigo,
                      onTap: () => context.push(Routes.security),
                    ),
                  ]),
                  group(l10n.settingsGroupSupport, [
                    AtListRow(
                      title: l10n.settingsHelp,
                      icon: LucideIcons.circleHelp,
                      tone: AtTone.indigo,
                      showDivider: true,
                      onTap: () => context.push(Routes.help),
                    ),
                    AtListRow(
                      title: l10n.settingsLegal,
                      icon: LucideIcons.fileText,
                      tone: AtTone.neutral,
                      onTap: () => context.push(Routes.legalList),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  AtButton(
                    label: l10n.signOut,
                    variant: AtButtonVariant.secondary,
                    loading: _signingOut,
                    onPressed: _signingOut ? null : _signOut,
                  ),
                  const SizedBox(height: 8),
                  AtCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AtListRow(
                      title: l10n.stDeleteAccount,
                      icon: LucideIcons.trash2,
                      destructive: true,
                      onTap: () => context.push(Routes.deleteAccount),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
