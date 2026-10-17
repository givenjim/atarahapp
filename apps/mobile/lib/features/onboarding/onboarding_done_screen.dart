import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import 'onboarding_providers.dart';

/// "Your creative journey starts here": the dark completion screen with the real Passport number and the real
/// completion percentage returned by the server.
class OnboardingDoneScreen extends ConsumerWidget {
  const OnboardingDoneScreen({super.key, required this.result});

  final OnboardingCompleteDto result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = result.state.profile;
    final percent = result.state.completion.percent.round();
    final spec = profile.specialisations.isEmpty
        ? l10n.obSpecNotSet
        : profile.specialisations.first.name;
    final discipline = profile.discipline?.name;
    final line = discipline == null ? spec : '$discipline · $spec';
    final where = profile.countyName == null
        ? l10n.obLocationNotSet
        : '${profile.countyName}, ${profile.countryName ?? ''}'.trim();
    final url = profile.avatarUrl;
    // ATR-NBI-0042 reads "ATR · NBI · 0042" on the card.
    final number = result.passport.passportNumber.replaceAll('-', ' · ');

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A36E0), Color(0xFF3B2BC4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(255, 255, 255, 0.18),
                        ),
                        child: const Icon(
                          LucideIcons.partyPopper,
                          size: 30,
                          color: AtColors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.obDoneTitle,
                          style: AtTextStyles.tabTitle.copyWith(
                            color: AtColors.white,
                            fontSize: 36,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.obDoneBody,
                        style: AtTextStyles.body.copyWith(
                          color: const Color.fromRGBO(255, 255, 255, 0.88),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Semantics(
                        container: true,
                        label:
                            '${l10n.obPassportLabel} ${result.passport.passportNumber}',
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: AtColors.white,
                            borderRadius: AtRadii.passport,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(20, 10, 80, 0.3),
                                blurRadius: 40,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.obPassportLabel,
                                    style: AtTextStyles.metaSm.copyWith(
                                      color: AtColors.muted,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    number,
                                    style: AtTextStyles.metaSm.copyWith(
                                      color: AtColors.muted,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  AtAvatar(
                                    name: profile.displayName,
                                    size: 64,
                                    shape: AtAvatarShape.rounded,
                                    image: url == null
                                        ? null
                                        : ref.watch(avatarImageProvider)(url),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.displayName,
                                          style: AtTextStyles.sectionTitle
                                              .copyWith(color: AtColors.ink),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          line,
                                          style: AtTextStyles.bodySm.copyWith(
                                            color: AtColors.body,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.mapPin,
                                              size: 12,
                                              color: AtColors.muted,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                where,
                                                style: AtTextStyles.meta
                                                    .copyWith(
                                                      color: AtColors.muted,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.obCompletion,
                                    style: AtTextStyles.meta.copyWith(
                                      color: AtColors.body,
                                    ),
                                  ),
                                  Text(
                                    '$percent%',
                                    style: AtTextStyles.meta.copyWith(
                                      color: AtColors.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              AtProgressBar(
                                value: percent / 100,
                                height: 8,
                                semanticLabel: l10n.obCompletion,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: AtSizes.buttonLg,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AtColors.white,
                      foregroundColor: const Color(0xFF4A36E0),
                      shape: const StadiumBorder(),
                      textStyle: AtTextStyles.button,
                    ),
                    onPressed: () => context.go(Routes.home),
                    child: Text(l10n.obGoHome),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
