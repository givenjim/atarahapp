import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../profile/profile_providers.dart';
import 'discover_common.dart';
import 'discover_providers.dart';

/// The Home tab. Everything on it comes from one aggregated request; a section with nothing to show is left out
/// rather than drawn empty, and a section that failed to load is left out while the rest still works.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(homeFeedProvider);
    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        bottom: false,
        child: feed.when(
          loading: () => const _HomeLoading(),
          error: (e, _) => Column(
            children: [
              const _HomeHeader(unread: 0),
              Expanded(
                child: loadFailure(
                  e,
                  () => ref.invalidate(homeFeedProvider),
                  l10n,
                ),
              ),
            ],
          ),
          data: (home) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(homeFeedProvider);
              await ref.read(homeFeedProvider.future);
            },
            child: _HomeBody(home: home),
          ),
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _HomeHeader(unread: 0),
      Padding(
        padding: EdgeInsets.all(AtSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtSkeleton(width: 220, height: 28),
            SizedBox(height: 12),
            AtSkeleton(height: 120, radius: 22),
            SizedBox(height: 24),
            AtSkeleton(height: 90),
          ],
        ),
      ),
    ],
  );
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(myProfileProvider).value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        10,
        AtSpacing.gutter,
        6,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(fit: BoxFit.scaleDown, child: AtWordmark()),
            ),
          ),
          AtIconButton(
            icon: LucideIcons.bell,
            semanticLabel: unread > 0
                ? l10n.dcNotificationsUnread(unread)
                : l10n.dcNotifications,
            variant: AtIconButtonVariant.back,
            showDot: unread > 0,
            onPressed: () => context.push(Routes.notifications),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: l10n.dcYourProfile,
            excludeSemantics: true,
            onTap: () => context.go(Routes.profile),
            child: GestureDetector(
              onTap: () => context.go(Routes.profile),
              child: Portrait(
                name: me?.displayName ?? '',
                url: me?.avatarUrl,
                size: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.home});

  final HomeDto home;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const pad = EdgeInsets.symmetric(horizontal: AtSpacing.gutter);
    Widget gap([double h = AtSpacing.sectionGap]) => SizedBox(height: h);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _HomeHeader(unread: home.unreadNotifications.toInt()),
        Padding(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Semantics(
                header: true,
                child: Text(
                  l10n.dcWelcome(home.firstName),
                  style: AtTextStyles.detailTitle.copyWith(color: AtColors.ink),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.dcWelcomeBody,
                style: AtTextStyles.body.copyWith(color: AtColors.body),
              ),
              if (home.completionPercent < 100) ...[
                gap(18),
                _CompletionCard(percent: home.completionPercent.toInt()),
              ],
              gap(),
              _QuickAccess(),
            ],
          ),
        ),
        if (home.recommended.isNotEmpty) ...[
          gap(AtSpacing.sectionGapLg),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtSectionHeader(title: l10n.dcRecommended),
                const SizedBox(height: 10),
                for (final r in home.recommended) ...[
                  _RecommendationTile(item: r),
                  const SizedBox(height: AtSpacing.listGap),
                ],
              ],
            ),
          ),
        ],
        if (home.creatives.isNotEmpty) ...[
          gap(AtSpacing.sectionGapLg),
          Padding(
            padding: pad,
            child: AtSectionHeader(
              title: l10n.dcCreativesToMeet,
              onSeeAll: () => context.go(Routes.explore),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: pad,
              itemCount: home.creatives.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => CreativeMiniCard(
                creative: home.creatives[i],
                onTap: () =>
                    context.push(Routes.creativePath(home.creatives[i].handle)),
              ),
            ),
          ),
        ],
        gap(AtSpacing.sectionGapLg),
        Padding(
          padding: pad,
          child: Row(
            children: [
              Expanded(
                child: _SoonTile(
                  icon: LucideIcons.store,
                  title: l10n.dcMarketplace,
                  body: l10n.dcMarketplaceBody,
                  phase: 'p2',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SoonTile(
                  icon: LucideIcons.handshake,
                  title: l10n.dcMentorship,
                  body: l10n.dcMentorshipBody,
                  phase: 'p2',
                ),
              ),
            ],
          ),
        ),
        if (home.article != null) ...[
          gap(AtSpacing.sectionGapLg),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtSectionHeader(
                  title: l10n.dcGrowCareer,
                  onSeeAll: () => context.push(Routes.articles),
                ),
                const SizedBox(height: 10),
                ArticleTile(
                  article: home.article!,
                  large: true,
                  onTap: () =>
                      context.push(Routes.articlePath(home.article!.slug)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtDarkCard(
      onTap: () => context.go(Routes.profile),
      child: Semantics(
        label: l10n.dcCompletionLabel(percent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 10,
              children: [
                Text(
                  '$percent%',
                  style: AtTextStyles.tabTitle.copyWith(color: AtColors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l10n.dcCompletion,
                    style: AtTextStyles.chip.copyWith(color: AtColors.violet3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AtProgressBar(value: percent / 100),
            const SizedBox(height: 12),
            Text(
              l10n.dcCompletionBody,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.violet3),
            ),
            const SizedBox(height: 14),
            AtButton(
              label: l10n.dcViewProfile,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () => context.go(Routes.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = <(IconData, String, VoidCallback)>[
      (
        LucideIcons.compass,
        l10n.featureExplore,
        () => context.go(Routes.explore),
      ),
      (
        LucideIcons.graduationCap,
        l10n.dcSkillLabs,
        () => context.push(Routes.soonPath('p1', name: l10n.dcSkillLabs)),
      ),
      (
        LucideIcons.briefcase,
        l10n.featureOpportunities,
        () => context.go(Routes.opportunities),
      ),
      (
        LucideIcons.users,
        l10n.featureCommunity,
        () => context.go(Routes.community),
      ),
      (
        LucideIcons.layoutGrid,
        l10n.dcPortfolio,
        () => context.push(Routes.portfolio),
      ),
      (
        LucideIcons.badgeCheck,
        l10n.dcPassport,
        () => context.push(Routes.passport),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtSectionHeader(title: l10n.dcQuickAccess),
        const SizedBox(height: 10),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            // Room for two lines of label however large the text is set.
            mainAxisExtent: 64 + 36 * MediaQuery.textScalerOf(context).scale(1),
          ),
          children: [
            for (final (icon, label, onTap) in tiles)
              Semantics(
                button: true,
                label: label,
                excludeSemantics: true,
                onTap: onTap,
                child: AtCard(
                  onTap: onTap,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 24, color: AtColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.chipSm.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationTile extends ConsumerWidget {
  const _RecommendationTile({required this.item});

  final RecommendationDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Why it is here, in the words the server chose.
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 13,
                color: AtColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.reason,
                  style: AtTextStyles.metaSm.copyWith(color: AtColors.primary),
                ),
              ),
            ],
          ),
        ),
        AtCard(
          onTap: () => context.push(item.path),
          padding: const EdgeInsets.all(14),
          semanticLabel: '${item.title}. ${item.reason}',
          child: Row(
            children: [
              const Icon(LucideIcons.bookOpen, color: AtColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: AtColors.ink,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: AtTextStyles.metaSm.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AtColors.faint,
                semanticLabel: l10n.dcOpen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoonTile extends StatelessWidget {
  const _SoonTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.phase,
  });

  final IconData icon;
  final String title;
  final String body;
  final String phase;

  @override
  Widget build(BuildContext context) => AtCard(
    onTap: () => context.push(Routes.soonPath(phase, name: title)),
    padding: const EdgeInsets.all(14),
    semanticLabel: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AtColors.primary),
        const SizedBox(height: 10),
        Text(
          title,
          style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 2),
        Text(body, style: AtTextStyles.metaSm.copyWith(color: AtColors.muted)),
      ],
    ),
  );
}
