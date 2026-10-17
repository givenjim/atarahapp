import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';

/// First screen for a signed-out member: collage, headline, the four pillars and the two ways in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final intended = GoRouterState.of(context).uri.queryParameters['from'];

    String withFrom(String path) => intended == null
        ? path
        : '$path?from=${Uri.encodeQueryComponent(intended)}';

    final pillars = [
      (LucideIcons.user, l10n.pillarIdentity, AtColors.tint1, AtColors.primary),
      (
        LucideIcons.graduationCap,
        l10n.pillarLearn,
        AtColors.successBg,
        AtColors.successStrong,
      ),
      (
        LucideIcons.users,
        l10n.pillarConnect,
        AtColors.pinkBg,
        AtColors.pinkStrong,
      ),
      (
        LucideIcons.briefcase,
        l10n.pillarEarn,
        AtColors.warningBg,
        AtColors.warningStrong,
      ),
    ];

    return Scaffold(
      body: AtPage(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  16,
                  AtSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtWordmark(size: 28),
                    const SizedBox(height: 26),
                    // Placeholder artwork from the design prototype; swap for licensed imagery when supplied.
                    SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          const Expanded(
                            child: _Photo(
                              asset: 'assets/images/p_zuri.png',
                              radius: 20,
                              height: 150,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                const Expanded(
                                  child: _Photo(
                                    asset: 'assets/images/p_amani.png',
                                    radius: 16,
                                    height: 70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: AtGradients.darkCard,
                                      borderRadius: AtRadii.card,
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          LucideIcons.sparkles,
                                          size: 18,
                                          color: AtColors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            l10n.tagline,
                                            maxLines: 2,
                                            style: AtTextStyles.metaSm.copyWith(
                                              color: AtColors.white,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.welcomeHeadline,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: AtColors.ink,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.welcomeSubhead,
                      style: AtTextStyles.body.copyWith(color: AtColors.body),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        for (var i = 0; i < pillars.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            child: _Pillar(
                              icon: pillars[i].$1,
                              label: pillars[i].$2,
                              bg: pillars[i].$3,
                              fg: pillars[i].$4,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                12,
                AtSpacing.gutter,
                10,
              ),
              child: Column(
                children: [
                  AtButton(
                    label: l10n.welcomeCreateAccount,
                    onPressed: () => context.push(Routes.signup),
                  ),
                  const SizedBox(height: 4),
                  AtButton(
                    label: l10n.welcomeSignIn,
                    variant: AtButtonVariant.secondary,
                    onPressed: () => context.push(withFrom(Routes.signin)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AtButton(
                        label: l10n.welcomeTerms,
                        variant: AtButtonVariant.tertiary,
                        size: AtButtonSize.sm,
                        fullWidth: false,
                        onPressed: () =>
                            context.push(Routes.legalPath('TERMS')),
                      ),
                      const SizedBox(width: 8),
                      AtButton(
                        label: l10n.welcomePrivacy,
                        variant: AtButtonVariant.tertiary,
                        size: AtButtonSize.sm,
                        fullWidth: false,
                        onPressed: () =>
                            context.push(Routes.legalPath('PRIVACY')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.asset,
    required this.radius,
    required this.height,
  });

  final String asset;
  final double radius;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _Pillar extends StatelessWidget {
  const _Pillar({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: AtRadii.card),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: fg),
          const SizedBox(height: 7),
          Text(
            label,
            style: AtTextStyles.metaSm.copyWith(
              color: AtColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
