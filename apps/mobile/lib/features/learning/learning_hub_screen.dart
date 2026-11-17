import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'learning_common.dart';
import 'learning_providers.dart';

/// Skill Labs: where the member left off, what is featured, the categories in their three groups, and what is
/// recommended with the reason why. Everything comes from one server payload.
class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(learningHubProvider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.learning,
        child: Column(
          children: [
            AtTopBar(
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
              actions: [
                AtButton(
                  label: l10n.lnMyLearning,
                  icon: LucideIcons.bookOpen,
                  size: AtButtonSize.sm,
                  variant: AtButtonVariant.secondary,
                  fullWidth: false,
                  onPressed: () => context.push(Routes.learningMine),
                ),
              ],
            ),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(learningHubProvider),
                  l10n,
                ),
                data: (hub) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(learningHubProvider);
                    await ref.read(learningHubProvider.future);
                  },
                  child: _Body(hub: hub),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.hub});

  final LearningHubDto hub;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final empty =
        hub.featured.isEmpty &&
        hub.recommended.isEmpty &&
        hub.continueLearning == null &&
        hub.categories.every((c) => c.count == 0);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.graduationCap,
                size: 24,
                color: context.at.primary,
              ),
              const SizedBox(height: 8),
              Semantics(
                header: true,
                child: Text(
                  l10n.lnHubTitle,
                  style: AtTextStyles.tabTitle.copyWith(
                    color: context.at.ink,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.lnHubSubtitle,
                style: AtTextStyles.body.copyWith(color: context.at.body),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (hub.continueLearning != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
            child: _ContinueCard(item: hub.continueLearning!),
          ),
        if (hub.featured.isNotEmpty) ...[
          _Title(l10n.lnFeatured),
          SizedBox(
            height: atScaledExtent(context, 232, textShare: 0.25),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
              itemCount: hub.featured.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _FeaturedCard(lab: hub.featured[i]),
            ),
          ),
        ],
        if (hub.categories.isNotEmpty) ...[
          _Title(l10n.lnCategories),
          for (final g in LearningCategoryGroup.values.where(
            (g) => g != LearningCategoryGroup.$unknown,
          ))
            _Group(
              group: g,
              categories: hub.categories.where((c) => c.group == g).toList(),
            ),
        ],
        if (hub.recommended.isNotEmpty) ...[
          _Title(l10n.lnRecommended),
          for (final r in hub.recommended)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                0,
                AtSpacing.gutter,
                AtSpacing.listGap,
              ),
              child: LabTile(
                lab: r.content,
                footer: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 14,
                        color: context.at.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          r.reason,
                          style: AtTextStyles.metaSm.copyWith(
                            color: context.at.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        if (empty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: AtEmptyState(
              icon: LucideIcons.graduationCap,
              title: l10n.lnHubEmptyTitle,
              body: l10n.lnHubEmptyBody,
            ),
          ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AtSpacing.gutter,
      AtSpacing.sectionGap,
      AtSpacing.gutter,
      10,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
      ),
    ),
  );
}

/// The dark "Continue learning" card with a ring that shows the real percentage.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item});

  final ContinueLearningDto item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = item.percent.toInt();
    final next = item.nextLessonTitle;
    final meta = next == null
        ? l10n.lnContinueMetaNoTitle(
            item.lessonsDone.toInt(),
            item.lessonCount.toInt(),
          )
        : l10n.lnContinueMeta(
            item.lessonsDone.toInt() + 1,
            item.lessonCount.toInt(),
            next,
          );
    return Semantics(
      button: true,
      label:
          '${l10n.lnContinueLearning}: ${item.content.title}, $meta, '
          '${l10n.lnPercentComplete(percent)}',
      excludeSemantics: true,
      onTap: () => _open(context),
      child: AtDarkCard(
        ring: true,
        onTap: () => _open(context),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lnContinueLabel,
                    style: AtTextStyles.chipSm.copyWith(
                      color: context.at.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: context.at.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.meta.copyWith(
                      color: context.at.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            AtProgressRing(
              value: percent / 100,
              size: 64,
              onDark: true,
              semanticLabel: l10n.lnPercentComplete(percent),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final lesson = item.nextLessonId;
    context.push(
      lesson == null
          ? Routes.coursePath(item.content.id)
          : Routes.lessonPath(lesson),
    );
  }
}

/// A featured Skill Lab: a picture with its source pill over it, then the title and what it takes.
class _FeaturedCard extends ConsumerWidget {
  const _FeaturedCard({required this.lab});

  final LearningCardDto lab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 236,
      child: AtCard(
        onTap: () => context.push(Routes.coursePath(lab.id)),
        padding: EdgeInsets.zero,
        semanticLabel:
            '${lab.title}, ${labSourceLabel(l10n, lab.source, lab.type)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: LabCover(
                    url: lab.coverUrl,
                    type: lab.type,
                    size: 236,
                    height: 116,
                    radius: BorderRadius.zero,
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: AtTag(
                    label: labSourceLabel(l10n, lab.source, lab.type),
                    tone: labSourceTone(lab.source),
                    solid: lab.source == ContentSource.atarah,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labMeta(l10n, lab),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
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

/// One of the three tinted groups with its categories as chips ("Portfolio Building · 12").
class _Group extends StatelessWidget {
  const _Group({required this.group, required this.categories});

  final LearningCategoryGroup group;
  final List<HubCategoryDto> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tone = groupTone(group).colorsOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        0,
        AtSpacing.gutter,
        AtSpacing.listGap,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: tone.bg, borderRadius: AtRadii.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(groupIcon(group), size: 18, color: tone.fg),
                const SizedBox(width: 8),
                Semantics(
                  header: true,
                  child: Text(
                    groupLabel(l10n, group),
                    style: AtTextStyles.chip.copyWith(color: tone.strong),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  Semantics(
                    button: true,
                    label:
                        '${c.name}, ${l10n.lnResourcesCount(c.count.toInt())}',
                    excludeSemantics: true,
                    onTap: () =>
                        context.push(Routes.learningCategoryPath(c.slug)),
                    child: InkWell(
                      borderRadius: AtRadii.pill,
                      onTap: () =>
                          context.push(Routes.learningCategoryPath(c.slug)),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.at.surface,
                          borderRadius: AtRadii.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.name,
                              style: AtTextStyles.chip.copyWith(
                                color: context.at.ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${c.count.toInt()}',
                              style: AtTextStyles.metaSm.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
