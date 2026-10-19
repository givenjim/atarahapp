import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../profile/profile_labels.dart';
import '../profile/profile_repository.dart';
import 'experience_screen.dart' show experienceRange;
import 'portfolio_common.dart';
import 'portfolio_providers.dart';
import 'portfolio_screen.dart';

String? _previewName(PublicProfilePreview? p) => switch (p) {
  PublicProfilePreview.public => 'public',
  PublicProfilePreview.members => 'members',
  null => null,
};

/// A short note for a section the viewer is not allowed to see (or that has nothing in it yet).
class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AtColors.muted),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
          ),
        ),
      ],
    ),
  );
}

Widget _failure(Object e, VoidCallback retry, AppLocalizations l10n) =>
    AtErrorState(
      title: l10n.pfLoadFailed,
      body: e is AppFailure ? e.message : const UnexpectedFailure().message,
      ctaLabel: l10n.retry,
      onCta: retry,
    );

/// The Portfolio tab of someone's profile: the projects this viewer may open, filtered by category.
class CreativePortfolioTab extends ConsumerStatefulWidget {
  const CreativePortfolioTab({
    super.key,
    required this.profile,
    required this.preview,
  });

  final PublicProfileDto profile;
  final PublicProfilePreview? preview;

  @override
  ConsumerState<CreativePortfolioTab> createState() =>
      _CreativePortfolioTabState();
}

class _CreativePortfolioTabState extends ConsumerState<CreativePortfolioTab> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.profile;
    if (p.lockedSections.contains(PublicProfileDtoLockedSections.portfolio)) {
      return _Note(
        icon: LucideIcons.lock,
        text: l10n.cpHidden(
          publicSectionLabel(l10n, PublicProfileDtoLockedSections.portfolio),
        ),
      );
    }
    final async = ref.watch(creativeProjectsProvider(p.handle, widget.preview));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          _failure(e, () => ref.invalidate(creativeProjectsProvider), l10n),
      data: (all) {
        if (all.isEmpty) {
          return _Note(icon: LucideIcons.layoutGrid, text: l10n.cpNoPortfolio);
        }
        final chips = <(String, String)>[
          ('ALL', l10n.pjAll),
          if (all.any((x) => x.featured)) ('FEATURED', l10n.pjFeatured),
          for (final c in projectCategories)
            if (all.any((x) => x.category.json == c))
              (c, categoryLabel(l10n, c)),
        ];
        final shown = [
          for (final x in all)
            if (_filter == 'ALL' ||
                (_filter == 'FEATURED' && x.featured) ||
                x.category.json == _filter)
              x,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chips.length > 2) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (key, label) in chips) ...[
                      AtChip(
                        label: label,
                        selected: _filter == key,
                        onTap: () => setState(() => _filter = key),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ProjectGrid(
              projects: shown,
              onOpen: (project) => context.push(
                Routes.projectPath(
                  project.id,
                  handle: p.handle,
                  preview: _previewName(widget.preview),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The Services tab of someone's profile.
class CreativeServicesTab extends ConsumerWidget {
  const CreativeServicesTab({
    super.key,
    required this.profile,
    required this.preview,
  });

  final PublicProfileDto profile;
  final PublicProfilePreview? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (profile.lockedSections.contains(
      PublicProfileDtoLockedSections.services,
    )) {
      return _Note(
        icon: LucideIcons.lock,
        text: l10n.cpHidden(
          publicSectionLabel(l10n, PublicProfileDtoLockedSections.services),
        ),
      );
    }
    final async = ref.watch(creativeServicesProvider(profile.handle, preview));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          _failure(e, () => ref.invalidate(creativeServicesProvider), l10n),
      data: (list) => list.isEmpty
          ? _Note(icon: LucideIcons.handshake, text: l10n.cpNoServices)
          : Column(
              children: [
                for (final s in list) ...[
                  AtCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: AtTextStyles.cardTitle.copyWith(
                            color: AtColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceText(l10n, s),
                          style: AtTextStyles.chip.copyWith(
                            color: AtColors.primary,
                          ),
                        ),
                        if (s.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.description!,
                            style: AtTextStyles.bodySm.copyWith(
                              color: AtColors.body,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

/// Experience and achievements, shown on the About tab when the Experience section is visible to the viewer.
class CreativeExperienceSection extends ConsumerWidget {
  const CreativeExperienceSection({
    super.key,
    required this.profile,
    required this.preview,
  });

  final PublicProfileDto profile;
  final PublicProfilePreview? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (!profile.visibleSections.contains(
      PublicProfileDtoVisibleSections.experience,
    )) {
      return const SizedBox.shrink();
    }
    final experience = ref
        .watch(creativeExperienceProvider(profile.handle, preview))
        .value;
    final achievements = ref
        .watch(creativeAchievementsProvider(profile.handle, preview))
        .value;

    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (experience != null && experience.isNotEmpty) ...[
          heading(l10n.secExperience),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, e) in experience.indexed)
                  AtListRow(
                    title: e.title,
                    subtitle:
                        '${e.organisation} · ${experienceRange(context, e)}',
                    icon: LucideIcons.briefcase,
                    tone: AtTone.warning,
                    showChevron: false,
                    showDivider: i < experience.length - 1,
                  ),
              ],
            ),
          ),
        ],
        if (achievements != null && achievements.isNotEmpty) ...[
          heading(l10n.pfAchievements),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, a) in achievements.indexed)
                  AtListRow(
                    title: a.title,
                    subtitle: [
                      achievementTypeLabel(l10n, a.type.json),
                      if (a.issuer != null) a.issuer!,
                      if (a.achievedOn != null)
                        monthYear(context, a.achievedOn),
                    ].join(' · '),
                    icon: achievementIcon(a.type.json),
                    tone: AtTone.amber,
                    showChevron: false,
                    showDivider: i < achievements.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
