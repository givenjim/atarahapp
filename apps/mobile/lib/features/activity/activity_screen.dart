import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/notification_route.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

(IconData, AtTone, String) _resumeLook(
  AppLocalizations l10n,
  ResumeCardDtoKind k,
) => switch (k) {
  ResumeCardDtoKind.lesson => (
    LucideIcons.circlePlay,
    AtTone.success,
    l10n.ayResumeLesson,
  ),
  ResumeCardDtoKind.opportunityGap => (
    LucideIcons.briefcase,
    AtTone.amber,
    l10n.ayResumeOpportunity,
  ),
  _ => (LucideIcons.penLine, AtTone.primary, l10n.ayResumeProject),
};

/// Activity: where the member left off, and a grid of what they have going on with live counts.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(activityHubProvider);
    return SubPage(
      title: l10n.ayActivityTitle,
      backTo: Routes.profile,
      wash: AtWash.standard,
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(activityHubProvider), l10n),
        data: (hub) {
          final c = hub.counts;
          Widget tile({
            required IconData icon,
            required AtTone tone,
            required String label,
            required String meta,
            required VoidCallback onTap,
          }) => _HubTile(
            icon: icon,
            tone: tone,
            label: label,
            meta: meta,
            onTap: onTap,
          );
          final tiles = [
            tile(
              icon: LucideIcons.bookmark,
              tone: AtTone.violet,
              label: l10n.ayTileSaved,
              meta: l10n.ayCount(c.saved.toInt()),
              onTap: () => context.push(Routes.saved),
            ),
            tile(
              icon: LucideIcons.briefcase,
              tone: AtTone.amber,
              label: l10n.ayTileApplications,
              meta: l10n.ayCount(c.applications.toInt()),
              onTap: () => context.push(Routes.applications),
            ),
            tile(
              icon: LucideIcons.graduationCap,
              tone: AtTone.success,
              label: l10n.ayTileLearning,
              meta: l10n.ayInProgressCount(c.learningInProgress.toInt()),
              onTap: () => context.push(Routes.learningMinePath()),
            ),
            tile(
              icon: LucideIcons.layoutGrid,
              tone: AtTone.primary,
              label: l10n.ayTilePortfolio,
              meta: l10n.ayCount(c.portfolio.toInt()),
              onTap: () => context.push(Routes.portfolio),
            ),
            tile(
              icon: LucideIcons.users,
              tone: AtTone.indigo,
              label: l10n.ayTileConnections,
              meta: l10n.ayPendingCount(c.pendingConnections.toInt()),
              onTap: () => context.push(Routes.connectionsPath()),
            ),
            tile(
              icon: LucideIcons.bell,
              tone: AtTone.warning,
              label: l10n.ayTileNotifications,
              meta: l10n.ayUnreadCount(c.unreadNotifications.toInt()),
              onTap: () => context.push(Routes.notifications),
            ),
            tile(
              icon: LucideIcons.users,
              tone: AtTone.violet,
              label: l10n.ayTileMentorship,
              meta: l10n.mnFindMentor,
              onTap: () => context.push(Routes.mentorship),
            ),
            tile(
              icon: LucideIcons.shoppingBag,
              tone: AtTone.coral,
              label: l10n.ayTileMarketplace,
              meta: l10n.mnFindMentor,
              onTap: () => context.push(
                Routes.soonPath('p2', name: l10n.ayTileMarketplace),
              ),
            ),
          ];
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activityHubProvider);
              await ref.read(activityHubProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    l10n.ayPickUp,
                    style: AtTextStyles.sectionTitleSm.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (hub.resume.isEmpty)
                  AtCard(
                    child: Text(
                      l10n.ayNothingToResume,
                      style: AtTextStyles.bodySm.copyWith(
                        color: context.at.body,
                      ),
                    ),
                  )
                else
                  for (final r in hub.resume) ...[
                    _ResumeCard(card: r),
                    const SizedBox(height: AtSpacing.listGap),
                  ],
                const SizedBox(height: 14),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    // About 136 at normal text (the old 1.25 ratio); taller as the text grows.
                    mainAxisExtent: atScaledExtent(
                      context,
                      136,
                      textShare: 0.7,
                    ),
                  ),
                  children: tiles,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.card});

  final ResumeCardDto card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, tone, kind) = _resumeLook(l10n, card.kind);
    return AtCard(
      semanticLabel: '$kind: ${card.title}',
      onTap: () {
        final route = resolveNotificationRoute(card.path);
        if (route != null) context.push(route);
      },
      child: Row(
        children: [
          AtIconTile(icon: icon, tone: tone, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind,
                  style: AtTextStyles.metaSm.copyWith(
                    color: context.at.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                if (card.subtitle != null)
                  Text(
                    card.subtitle!,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
                  ),
                if (card.progressPercent != null) ...[
                  const SizedBox(height: 6),
                  AtProgressBar(value: card.progressPercent!.toDouble() / 100),
                ],
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: context.at.muted),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.tone,
    required this.label,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final AtTone tone;
  final String label;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colorsOf(context);
    return Semantics(
      button: true,
      label: '$label. $meta',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: colors.bg,
        borderRadius: AtRadii.cardLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AtRadii.cardLg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 22, color: colors.fg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    Text(
                      meta,
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.body,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
