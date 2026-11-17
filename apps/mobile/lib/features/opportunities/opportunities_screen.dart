import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'opportunities_common.dart';
import 'opportunities_providers.dart';

/// The Opportunities tab: a saved button with its count, search, category tiles, then Featured, Closing soon
/// and Recently added. Every opportunity's save, deadline and trust badge come from the server.
class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(opportunitiesHomeProvider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.opportunities,
        child: async.when(
          skipLoadingOnReload: true,
          loading: () => const AtLoadingBody(),
          error: (e, _) => Column(
            children: [
              const _Header(savedCount: 0),
              Expanded(
                child: loadFailure(
                  e,
                  () => ref.invalidate(opportunitiesHomeProvider),
                  l10n,
                ),
              ),
            ],
          ),
          data: (home) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(opportunitiesHomeProvider);
              await ref.read(opportunitiesHomeProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _Header(savedCount: home.savedCount.toInt()),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
                  child: _SearchEntry(),
                ),
                const SizedBox(height: 14),
                _Categories(categories: home.categories),
                if (home.featured.isNotEmpty) ...[
                  _SectionTitle(l10n.opFeatured),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AtSpacing.gutter,
                    ),
                    child: _FeaturedCard(opportunity: home.featured.first),
                  ),
                ],
                if (home.closingSoon.isNotEmpty) ...[
                  _SectionTitle(
                    l10n.opClosingSoon,
                    onSeeAll: () =>
                        context.push(Routes.opportunitiesListPath()),
                  ),
                  _Cards(home.closingSoon),
                ],
                if (home.recent.isNotEmpty) ...[
                  _SectionTitle(l10n.opRecent),
                  _Cards(home.recent),
                ],
                if (home.featured.isEmpty &&
                    home.closingSoon.isEmpty &&
                    home.recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: AtEmptyState(
                      icon: LucideIcons.briefcase,
                      title: l10n.opNothingOpen,
                      body: l10n.opNothingOpenBody,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.savedCount});

  final int savedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        14,
        AtSpacing.gutter,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.briefcase,
                  size: 24,
                  color: context.at.tangerine,
                ),
                const SizedBox(height: 8),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.featureOpportunities,
                    style: AtTextStyles.tabTitle.copyWith(
                      color: context.at.ink,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.opSubtitle,
                  style: AtTextStyles.body.copyWith(color: context.at.body),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AtIconButton(
              icon: LucideIcons.bookmark,
              semanticLabel: l10n.opSavedCount(savedCount),
              badge: savedCount,
              onPressed: () =>
                  context.push(Routes.myOpportunitiesPath(tab: 'saved')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => context.push(Routes.search);
    return Semantics(
      button: true,
      label: l10n.opSearchHint,
      excludeSemantics: true,
      onTap: open,
      child: GestureDetector(
        onTap: open,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.at.inputFill,
            borderRadius: AtRadii.input,
            border: Border.all(color: context.at.inputBorder),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.search, size: 18, color: context.at.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.opSearchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.body.copyWith(color: context.at.faint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// All, then the categories the server counted, in the prototype's order.
class _Categories extends StatelessWidget {
  const _Categories({required this.categories});

  final List<OpportunityCategoryCountDto> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = <OpportunityType?>[null, ...categories.map((c) => c.type)];
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AtSpacing.gutter,
          vertical: 6,
        ),
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final type = tiles[i];
          final label = opportunityCategoryLabel(l10n, type);
          final selected = type == null;
          final fg = selected ? context.at.white : context.at.ink;
          return Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            onTap: () =>
                context.push(Routes.opportunitiesListPath(type: type?.json)),
            child: GestureDetector(
              onTap: () =>
                  context.push(Routes.opportunitiesListPath(type: type?.json)),
              child: Container(
                constraints: const BoxConstraints(minWidth: 84),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? context.at.primaryFill : context.at.surface,
                  borderRadius: AtRadii.tile,
                  border: Border.all(
                    color: selected
                        ? context.at.primaryFill
                        : context.at.cardBorder,
                  ),
                  boxShadow: selected ? context.at.shadowCta : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(opportunityTypeIcon(type), size: 20, color: fg),
                    const SizedBox(height: 8),
                    Text(label, style: AtTextStyles.chipSm.copyWith(color: fg)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AtSpacing.gutter,
      AtSpacing.sectionGap,
      AtSpacing.gutter,
      10,
    ),
    child: AtSectionHeader(title: title, onSeeAll: onSeeAll),
  );
}

class _Cards extends StatelessWidget {
  const _Cards(this.items);

  final List<OpportunityCardDto> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
    child: Column(
      children: [
        for (final o in items) ...[
          OpportunityTile(opportunity: o),
          const SizedBox(height: AtSpacing.listGap),
        ],
      ],
    ),
  );
}

/// The one featured opportunity as a dark card with its trust badge, title and what it pays.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.opportunity});

  final OpportunityCardDto opportunity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = opportunity;
    final sub = [o.provider.name, ?o.valueLabel].join(' · ');
    return Semantics(
      button: true,
      label: '${o.title}, $sub',
      excludeSemantics: true,
      onTap: () => context.push(Routes.opportunityPath(o.id)),
      child: GestureDetector(
        onTap: () => context.push(Routes.opportunityPath(o.id)),
        child: AtDarkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AtTag(
                    label: trustLabel(l10n, o.trust),
                    tone: AtTone.primary,
                    icon: trustIcon(o.trust),
                  ),
                  const SizedBox(width: 6),
                  AtTag(
                    label: opportunityTypeLabel(l10n, o.type),
                    tone: AtTone.violet,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                o.title,
                style: AtTextStyles.detailTitle.copyWith(
                  color: context.at.white,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sub,
                style: AtTextStyles.meta.copyWith(
                  color: context.at.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
