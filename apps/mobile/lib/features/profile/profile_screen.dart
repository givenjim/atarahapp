import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';

/// Profile tab. Shows the signed-in member (real data from the API) and Sign out. Passport, activity,
/// membership and settings open their labelled placeholders until their milestones land.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    final user = ref.watch(sessionControllerProvider).value;
    final isPro = user?.membership.plan.name.toLowerCase() == 'pro';

    return AtPage(
      wash: AtWash.settings,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          AtSpacing.gutter,
          AtSpacing.gutter,
          AtSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.tabProfile,
                style: AtTextStyles.tabTitle.copyWith(color: AtColors.ink),
              ),
            ),
            const SizedBox(height: 20),
            if (user != null)
              AtCard(
                child: Row(
                  children: [
                    AtAvatar(
                      name: user.fullName,
                      size: AtAvatar.lg,
                      shape: AtAvatarShape.rounded,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: AtTextStyles.sectionTitle.copyWith(
                              color: AtColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email ?? user.phone ?? '',
                            style: AtTextStyles.meta.copyWith(
                              color: AtColors.muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AtTag(
                            label: isPro
                                ? l10n.profileMembershipPro
                                : l10n.profileMembershipFree,
                            tone: isPro ? AtTone.amber : AtTone.neutral,
                            icon: isPro ? LucideIcons.crown : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            AtCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AtListRow(
                    title: l10n.profileCreativePassport,
                    icon: LucideIcons.idCard,
                    showDivider: true,
                    onTap: () => context.push(
                      Routes.soonPath('p1', name: l10n.profileCreativePassport),
                    ),
                  ),
                  AtListRow(
                    title: l10n.profileActivity,
                    icon: LucideIcons.activity,
                    tone: AtTone.warning,
                    showDivider: true,
                    onTap: () => context.push(
                      Routes.soonPath('p1', name: l10n.profileActivity),
                    ),
                  ),
                  AtListRow(
                    title: l10n.profileMembership,
                    icon: LucideIcons.crown,
                    tone: AtTone.amber,
                    showDivider: true,
                    onTap: () => context.push(
                      Routes.soonPath('p1', name: l10n.profileMembership),
                    ),
                  ),
                  AtListRow(
                    title: l10n.profileSettings,
                    icon: LucideIcons.settings,
                    tone: AtTone.purple,
                    onTap: () => context.push(
                      Routes.soonPath('p1', name: l10n.profileSettings),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AtButton(
              label: l10n.signOut,
              variant: AtButtonVariant.destructive,
              loading: _signingOut,
              icon: LucideIcons.logOut,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
