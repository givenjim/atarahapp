import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart' show avatarImageProvider;
import 'learning_providers.dart';

/// "Course", "Masterclass": what kind of Skill Lab it is.
String labTypeLabel(AppLocalizations l10n, LearningContentType? t) =>
    switch (t) {
      null => l10n.lnTypeAll,
      LearningContentType.course => l10n.lnTypeCourse,
      LearningContentType.tutorial => l10n.lnTypeTutorial,
      LearningContentType.toolkit => l10n.lnTypeToolkit,
      LearningContentType.webinar => l10n.lnTypeWebinar,
      LearningContentType.masterclass => l10n.lnTypeMasterclass,
      LearningContentType.article => l10n.lnTypeArticle,
      LearningContentType.$unknown => l10n.lnTypeAll,
    };

/// "masterclasses": the type in the plural, for the empty state of a category.
String labTypePlural(AppLocalizations l10n, LearningContentType? t) =>
    switch (t) {
      LearningContentType.course => l10n.lnPluralCourse,
      LearningContentType.tutorial => l10n.lnPluralTutorial,
      LearningContentType.toolkit => l10n.lnPluralToolkit,
      LearningContentType.webinar => l10n.lnPluralWebinar,
      LearningContentType.masterclass => l10n.lnPluralMasterclass,
      LearningContentType.article => l10n.lnPluralArticle,
      _ => l10n.lnPluralAll,
    };

IconData labTypeIcon(LearningContentType? t) => switch (t) {
  LearningContentType.course => LucideIcons.graduationCap,
  LearningContentType.tutorial => LucideIcons.playCircle,
  LearningContentType.toolkit => LucideIcons.wrench,
  LearningContentType.webinar => LucideIcons.video,
  LearningContentType.masterclass => LucideIcons.award,
  LearningContentType.article => LucideIcons.bookOpen,
  _ => LucideIcons.graduationCap,
};

/// "✓ Atarah Course", "Partner content", "External resource" (Master Prompt 6.4).
String labSourceLabel(
  AppLocalizations l10n,
  ContentSource source,
  LearningContentType type,
) => switch (source) {
  ContentSource.atarah =>
    type == LearningContentType.article
        ? l10n.lnSourceAtarahEditorial
        : l10n.lnSourceAtarahCourse,
  ContentSource.partner => l10n.lnSourcePartner,
  _ => l10n.lnSourceExternal,
};

AtTone labSourceTone(ContentSource source) => switch (source) {
  ContentSource.atarah => AtTone.primary,
  ContentSource.partner => AtTone.indigo,
  _ => AtTone.neutral,
};

/// "In-app lessons", "Embedded", "Opens outside Atarah".
String labDeliveryLabel(AppLocalizations l10n, ContentDelivery d) =>
    switch (d) {
      ContentDelivery.native => l10n.lnDeliveryNative,
      ContentDelivery.embedded => l10n.lnDeliveryEmbedded,
      _ => l10n.lnDeliveryExternal,
    };

String labLevelLabel(AppLocalizations l10n, SkillLevel level) =>
    switch (level) {
      SkillLevel.beginner => l10n.lnLevelBeginner,
      SkillLevel.intermediate => l10n.lnLevelIntermediate,
      SkillLevel.advanced => l10n.lnLevelAdvanced,
      SkillLevel.expert => l10n.lnLevelExpert,
      _ => l10n.lnLevelBeginner,
    };

/// "1h 20m", "45 min".
String labDuration(AppLocalizations l10n, num minutes) {
  final m = minutes.round();
  if (m < 60) return l10n.lnDurationM(m);
  final h = m ~/ 60;
  final rest = m % 60;
  return rest == 0 ? l10n.lnDurationH(h) : l10n.lnDurationHm(h, rest);
}

String groupLabel(AppLocalizations l10n, LearningCategoryGroup g) =>
    switch (g) {
      LearningCategoryGroup.creative => l10n.lnGroupCreative,
      LearningCategoryGroup.business => l10n.lnGroupBusiness,
      _ => l10n.lnGroupProfessional,
    };

/// The three tinted groups on the hub.
AtTone groupTone(LearningCategoryGroup g) => switch (g) {
  LearningCategoryGroup.creative => AtTone.violet,
  LearningCategoryGroup.business => AtTone.amber,
  _ => AtTone.success,
};

IconData groupIcon(LearningCategoryGroup g) => switch (g) {
  LearningCategoryGroup.creative => LucideIcons.palette,
  LearningCategoryGroup.business => LucideIcons.briefcase,
  _ => LucideIcons.badgeCheck,
};

String labError(Object e) =>
    e is AppFailure ? e.message : const UnexpectedFailure().message;

void showLabNotice(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

bool isPremiumRequired(Object e) =>
    e is ApiFailure && e.code == 'PREMIUM_REQUIRED';

/// "Learning · Meta" line of a card: the level and how long it takes.
String labMeta(AppLocalizations l10n, LearningCardDto c) => [
  labLevelLabel(l10n, c.level),
  if (c.lessonCount != null && c.type == LearningContentType.course)
    l10n.lnLessonCount(c.lessonCount!.toInt()),
  if (c.durationMinutes > 0) labDuration(l10n, c.durationMinutes),
].join(' · ');

/// The picture of a Skill Lab, or a tinted tile with its type icon when it has none.
class LabCover extends ConsumerWidget {
  const LabCover({
    super.key,
    required this.url,
    required this.type,
    this.size = 64,
    this.height,
    this.radius = AtRadii.tileLg,
  });

  final String? url;
  final LearningContentType type;
  final double size;

  /// Defaults to [size] (a square); set it for a wide picture.
  final double? height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = url == null ? null : ref.watch(avatarImageProvider)(url!);
    return Container(
      width: size,
      height: height ?? size,
      decoration: BoxDecoration(
        gradient: image == null ? AtGradients.ctaSquare : null,
        borderRadius: radius,
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: image == null
          // A wide cover has an unbounded width; the icon follows the height.
          ? Icon(
              labTypeIcon(type),
              color: context.at.white,
              size: (height ?? size).clamp(0.0, 240.0) * 0.42,
            )
          : null,
    );
  }
}

/// A Skill Lab in any list: cover, type and source pills, title, level and length, a progress bar when the member
/// has started, and a bookmark that flips at once and flips back (with the server's words) when saving fails.
class LabTile extends ConsumerWidget {
  const LabTile({super.key, required this.lab, this.footer});

  final LearningCardDto lab;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = lab;
    final saved = ref.watch(learningSavesProvider)[c.id] ?? c.saved;
    final percent = c.progress?.percent.toInt();
    final started = c.progress != null;
    return AtCard(
      onTap: () => context.push(Routes.coursePath(c.id)),
      semanticLabel: [
        c.title,
        labTypeLabel(l10n, c.type),
        labSourceLabel(l10n, c.source, c.type),
        labMeta(l10n, c),
        if (started) l10n.lnPercentComplete(percent ?? 0),
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabCover(url: c.coverUrl, type: c.type),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        AtTag(
                          label: labTypeLabel(l10n, c.type),
                          icon: labTypeIcon(c.type),
                        ),
                        AtTag(
                          label: labSourceLabel(l10n, c.source, c.type),
                          tone: labSourceTone(c.source),
                        ),
                        if (c.access == LearningAccess.premiumContent)
                          AtTag(
                            label: l10n.lnPremiumBadge,
                            tone: AtTone.amber,
                            icon: LucideIcons.crown,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labMeta(l10n, c),
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AtTapTarget(
                onTap: () => toggleLabSave(context, ref, c.id, saved),
                semanticLabel: saved ? l10n.lnUnsaveLab : l10n.lnSaveLab,
                child: Icon(
                  saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                  size: 22,
                  color: saved ? context.at.primary : context.at.muted,
                ),
              ),
            ],
          ),
          if (started) ...[
            const SizedBox(height: 12),
            AtProgressBar(
              value: (c.progress!.percent.toDouble()) / 100,
              semanticLabel: l10n.lnPercentComplete(percent ?? 0),
            ),
          ],
          ?footer,
        ],
      ),
    );
  }
}

/// Flips a bookmark; a refusal rolls it back and says why.
Future<void> toggleLabSave(
  BuildContext context,
  WidgetRef ref,
  String id,
  bool currentlySaved,
) async {
  try {
    await ref
        .read(learningSavesProvider.notifier)
        .toggle(id, currentlySaved: currentlySaved);
  } on Object catch (e) {
    if (context.mounted) showLabNotice(context, labError(e));
  }
}

/// The lock screen for premium content: the shared gate, with Skill Labs wording. The price comes from the
/// membership settings once those are readable; until then the button just says "See Pro".
class LabPremiumGate extends StatelessWidget {
  const LabPremiumGate({super.key, this.priceLabel = ''});

  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtPremiumGate(
      feature: l10n.lnPremiumFeature,
      whatItDoes: l10n.lnPremiumWhat,
      whyItMatters: l10n.lnPremiumWhy,
      howToGet: l10n.lnPremiumHow,
      priceLabel: priceLabel,
      onSeePro: () => context.push(Routes.soonPath('p2', name: 'Atarah Pro')),
    );
  }
}

/// The body of a lesson as blocks (paragraph, heading, callout, quote, image). Never HTML.
class LessonBlocks extends ConsumerWidget {
  const LessonBlocks({super.key, required this.blocks});

  final List<ArticleBlockDto> blocks;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [for (final b in blocks) _Block(block: b)],
  );
}

class _Block extends ConsumerWidget {
  const _Block({required this.block});

  final ArticleBlockDto block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = block;
    switch (b.type) {
      case ArticleBlockDtoType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(
              b.text ?? '',
              style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
            ),
          ),
        );
      case ArticleBlockDtoType.callout:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.at.primaryTintFaint,
              borderRadius: AtRadii.card,
              border: Border.all(color: context.at.secondaryBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.title != null)
                  Text(
                    b.title!,
                    style: AtTextStyles.chip.copyWith(
                      color: context.at.primary,
                    ),
                  ),
                if (b.title != null) const SizedBox(height: 6),
                Text(
                  b.text ?? '',
                  style: AtTextStyles.body.copyWith(color: context.at.longForm),
                ),
              ],
            ),
          ),
        );
      case ArticleBlockDtoType.quote:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.at.primaryLight, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.text ?? '',
                  style: AtTextStyles.bodyLg.copyWith(
                    color: context.at.ink,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (b.attribution != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    b.attribution!,
                    style: AtTextStyles.metaSm.copyWith(
                      color: context.at.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      case ArticleBlockDtoType.image:
        final url = b.imageUrl;
        if (url == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: AtRadii.card,
            child: Image(
              image: ref.watch(avatarImageProvider)(url),
              fit: BoxFit.cover,
              width: double.infinity,
              semanticLabel: b.caption ?? '',
            ),
          ),
        );
      case ArticleBlockDtoType.paragraph:
      case ArticleBlockDtoType.$unknown:
        if ((b.text ?? '').isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            b.text!,
            style: AtTextStyles.bodyLg.copyWith(
              color: context.at.longForm,
              height: 1.6,
            ),
          ),
        );
    }
  }
}
