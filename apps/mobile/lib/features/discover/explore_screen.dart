import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_icons.dart';
import '../onboarding/onboarding_providers.dart';
import 'discover_common.dart';
import 'discover_providers.dart';
import 'discover_repository.dart';
import 'filters_sheet.dart';

/// The Explore tab: discipline tiles, then creatives in that discipline, then ways into the rest of Atarah.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(exploreCreativesProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(exploreFiltersProvider);
    final list = ref.watch(exploreCreativesProvider);
    final disciplines = ref.watch(disciplinesProvider).value ?? const [];
    const pad = EdgeInsets.symmetric(horizontal: AtSpacing.gutter);

    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(exploreCreativesProvider);
            await ref.read(exploreCreativesProvider.future);
          },
          child: ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  14,
                  AtSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.dcExploreTitle,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: AtColors.ink,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dcExploreBody,
                      style: AtTextStyles.body.copyWith(color: AtColors.body),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SearchBar(
                            onTap: () => context.push(Routes.search),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AtIconButton(
                          icon: LucideIcons.slidersHorizontal,
                          semanticLabel: l10n.dcFilters,
                          variant: AtIconButtonVariant.filter,
                          showDot: filters.activeCount > 0,
                          onPressed: () => showFiltersSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: pad,
                  children: [
                    AtChip(
                      label: l10n.dcAll,
                      selected: filters.disciplineId == null,
                      onTap: () => ref
                          .read(exploreFiltersProvider.notifier)
                          .set(filters.copyWith(disciplineId: null)),
                    ),
                    for (final d in disciplines) ...[
                      const SizedBox(width: 8),
                      AtChip(
                        label: d.name,
                        icon: lucideByName(d.icon),
                        selected: filters.disciplineId == d.id,
                        onTap: () => ref
                            .read(exploreFiltersProvider.notifier)
                            .set(filters.copyWith(disciplineId: d.id)),
                      ),
                    ],
                  ],
                ),
              ),
              if (filters.activeCount > 0) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: pad,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (filters.countyName != null)
                        AtChip(
                          label: filters.countyName!,
                          kind: AtChipKind.removable,
                          removeSemanticLabel: l10n.dcRemoveFilter(
                            filters.countyName!,
                          ),
                          onRemove: () => ref
                              .read(exploreFiltersProvider.notifier)
                              .set(
                                filters.copyWith(
                                  countyId: null,
                                  countyName: null,
                                ),
                              ),
                        ),
                      if (filters.available)
                        AtChip(
                          label: l10n.dcOpenToCommissions,
                          kind: AtChipKind.removable,
                          removeSemanticLabel: l10n.dcRemoveFilter(
                            l10n.dcOpenToCommissions,
                          ),
                          onRemove: () => ref
                              .read(exploreFiltersProvider.notifier)
                              .set(filters.copyWith(available: false)),
                        ),
                      if (filters.verified)
                        AtChip(
                          label: l10n.dcVerifiedOnly,
                          kind: AtChipKind.removable,
                          removeSemanticLabel: l10n.dcRemoveFilter(
                            l10n.dcVerifiedOnly,
                          ),
                          onRemove: () => ref
                              .read(exploreFiltersProvider.notifier)
                              .set(filters.copyWith(verified: false)),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Padding(
                padding: pad,
                child: list.when(
                  loading: () => Column(
                    children: [
                      for (var i = 0; i < 3; i++) ...const [
                        AtSkeleton(height: 120, radius: 18),
                        SizedBox(height: 12),
                      ],
                    ],
                  ),
                  error: (e, _) => loadFailure(
                    e,
                    () => ref.invalidate(exploreCreativesProvider),
                    l10n,
                  ),
                  data: (page) => _Results(page: page, filters: filters),
                ),
              ),
              const SizedBox(height: AtSpacing.sectionGapLg),
              const Padding(padding: pad, child: _MoreToExplore()),
              const SizedBox(height: AtSpacing.sectionGap),
              Padding(
                padding: pad,
                child: AtCard(
                  onTap: () => context.push(Routes.passport),
                  padding: const EdgeInsets.all(16),
                  semanticLabel: l10n.dcDiscoveredTitle,
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.badgeCheck,
                        color: AtColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dcDiscoveredTitle,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: AtColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.dcDiscoveredBody,
                              style: AtTextStyles.bodySm.copyWith(
                                color: AtColors.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.dcSearchHint,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AtColors.inputFill,
            borderRadius: AtRadii.input,
            border: Border.all(color: AtColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.search, size: 18, color: AtColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dcSearchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.body.copyWith(color: AtColors.faint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.page, required this.filters});

  final CreativeList page;
  final CreativeFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (page.items.isEmpty) {
      final narrowed = filters.disciplineId != null || filters.activeCount > 0;
      return AtEmptyState(
        icon: LucideIcons.users,
        title: narrowed ? l10n.dcNoCreativesNearby : l10n.dcNoCreativesYet,
        body: narrowed ? null : l10n.dcNoCreativesYetBody,
        ctaLabel: narrowed ? l10n.dcShowAll : null,
        onCta: narrowed
            ? () => ref.read(exploreFiltersProvider.notifier).reset()
            : null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dcCreativesCount(page.total),
          style: AtTextStyles.chip.copyWith(color: AtColors.muted),
        ),
        const SizedBox(height: 10),
        for (final c in page.items) ...[
          CreativeCard(
            creative: c,
            onTap: () => context.push(Routes.creativePath(c.handle)),
          ),
          const SizedBox(height: AtSpacing.listGap),
        ],
        if (page.loadingMore)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (page.moreFailed)
          AtButton(
            label: l10n.retry,
            variant: AtButtonVariant.tertiary,
            onPressed: () =>
                ref.read(exploreCreativesProvider.notifier).loadMore(),
          ),
      ],
    );
  }
}

class _MoreToExplore extends StatelessWidget {
  const _MoreToExplore();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = <(IconData, String, String, VoidCallback)>[
      (
        LucideIcons.graduationCap,
        l10n.dcSkillLabs,
        l10n.dcSkillLabsBody,
        () => context.push(Routes.soonPath('p1', name: l10n.dcSkillLabs)),
      ),
      (
        LucideIcons.briefcase,
        l10n.featureOpportunities,
        l10n.dcOpportunitiesBody,
        () => context.go(Routes.opportunities),
      ),
      (
        LucideIcons.store,
        l10n.dcMarketplace,
        l10n.dcMarketplaceBody,
        () => context.push(Routes.soonPath('p2', name: l10n.dcMarketplace)),
      ),
      (
        LucideIcons.handshake,
        l10n.dcMentorship,
        l10n.dcMentorshipBody,
        () => context.push(Routes.soonPath('p2', name: l10n.dcMentorship)),
      ),
      (
        LucideIcons.bookOpen,
        l10n.dcArticles,
        l10n.dcArticlesBody,
        () => context.push(Routes.articles),
      ),
      (
        LucideIcons.chartNoAxesColumn,
        l10n.dcCreativeEconomy,
        l10n.dcCreativeEconomyBody,
        () => context.push(Routes.soonPath('p3', name: l10n.dcCreativeEconomy)),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtSectionHeader(title: l10n.dcMoreToExplore),
        const SizedBox(height: 10),
        for (final (icon, title, body, onTap) in tiles) ...[
          AtCard(
            onTap: onTap,
            padding: const EdgeInsets.all(14),
            semanticLabel: '$title. $body',
            child: Row(
              children: [
                Icon(icon, color: AtColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AtTextStyles.cardTitle.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                      Text(
                        body,
                        style: AtTextStyles.metaSm.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AtColors.faint,
                ),
              ],
            ),
          ),
          const SizedBox(height: AtSpacing.listGap),
        ],
      ],
    );
  }
}
