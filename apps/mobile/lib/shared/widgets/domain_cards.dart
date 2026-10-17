import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// Domain widgets are presentational: every string, number and image comes in as a parameter. They never
/// fetch data and never embed sample content.

ImageProvider? _img(String? url) => url == null ? null : NetworkImage(url);

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saved,
    required this.onTap,
    required this.title,
  });

  final bool saved;
  final VoidCallback? onTap;
  final String title;

  @override
  Widget build(BuildContext context) => AtTapTarget(
    onTap: onTap,
    semanticLabel: saved
        ? AppLocalizations.of(context).unsaveItem(title)
        : AppLocalizations.of(context).saveItem(title),
    child: Icon(
      saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
      size: 20,
      color: saved ? AtColors.primary : AtColors.muted,
    ),
  );
}

/// A member in discovery lists ("Creatives to meet", Explore).
class CreativeCard extends StatelessWidget {
  const CreativeCard({
    super.key,
    required this.name,
    required this.roleLine,
    this.location,
    this.tags = const [],
    this.imageUrl,
    this.verified = false,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.actionSelected = false,
    this.reason,
  });

  final String name;
  final String roleLine;
  final String? location;
  final List<String> tags;
  final String? imageUrl;
  final bool verified;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// True once the action was taken (e.g. "Requested").
  final bool actionSelected;

  /// Why this person is suggested ("Also works in Animation").
  final String? reason;

  @override
  Widget build(BuildContext context) {
    // At large text sizes the action drops below the details so the name keeps its width.
    final stackAction = MediaQuery.textScalerOf(context).scale(14) > 20;
    final action = actionLabel == null
        ? null
        : AtButton(
            label: actionLabel!,
            size: AtButtonSize.sm,
            fullWidth: false,
            variant: actionSelected
                ? AtButtonVariant.secondary
                : AtButtonVariant.primary,
            onPressed: onAction,
          );
    final details = _details();
    return AtCard(
      onTap: onTap,
      semanticLabel: '$name, $roleLine',
      child: stackAction && action != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [details, const SizedBox(height: 10), action],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: details),
                if (action != null) ...[const SizedBox(width: 8), action],
              ],
            ),
    );
  }

  Widget _details() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtAvatar(
          name: name,
          image: _img(imageUrl),
          size: 64,
          shape: AtAvatarShape.rounded,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: AtColors.ink,
                      ),
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(width: 6),
                    const AtVerifiedTick(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                roleLine,
                style: AtTextStyles.meta.copyWith(color: AtColors.body),
              ),
              if (location != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 12,
                        color: AtColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.meta.copyWith(
                            color: AtColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (reason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    reason!,
                    style: AtTextStyles.metaSm.copyWith(
                      color: AtColors.primary,
                    ),
                  ),
                ),
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in tags)
                        AtTag(label: t, tone: AtTone.primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// How close a deadline is. ≤ 7 days pink, 8–14 days orange, otherwise neutral.
enum DeadlineUrgency { none, soon, closing }

DeadlineUrgency deadlineUrgency(
  DateTime? deadline,
  DateTime now, {
  bool finished = false,
}) {
  if (deadline == null || finished) return DeadlineUrgency.none;
  final days = deadline.difference(now).inHours / 24;
  if (days < 0) return DeadlineUrgency.none;
  if (days <= 7) return DeadlineUrgency.closing;
  if (days <= 14) return DeadlineUrgency.soon;
  return DeadlineUrgency.none;
}

enum OpportunityTrustLevel { verified, sourceConfirmed, externalSource }

/// Opportunity row with trust badge, value, deadline urgency and save.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.title,
    required this.providerName,
    required this.typeLabel,
    required this.trust,
    required this.deadlineLabel,
    required this.urgency,
    this.valueLabel,
    this.locationLabel,
    this.saved = false,
    this.onSave,
    this.onTap,
    this.trackingLabel,
  });

  final String title;
  final String providerName;
  final String typeLabel;
  final OpportunityTrustLevel trust;
  final String deadlineLabel;
  final DeadlineUrgency urgency;
  final String? valueLabel;
  final String? locationLabel;
  final bool saved;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  /// "Applied", "In progress", "Completed".
  final String? trackingLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (trustLabel, trustTone, trustIcon) = switch (trust) {
      OpportunityTrustLevel.verified => (
        l10n.verifiedByAtarah,
        AtTone.primary,
        LucideIcons.badgeCheck,
      ),
      OpportunityTrustLevel.sourceConfirmed => (
        l10n.sourceConfirmed,
        AtTone.info,
        LucideIcons.circleCheck,
      ),
      OpportunityTrustLevel.externalSource => (
        l10n.externalSource,
        AtTone.neutral,
        LucideIcons.globe,
      ),
    };
    final urgent = switch (urgency) {
      DeadlineUrgency.closing => AtTone.pink,
      DeadlineUrgency.soon => AtTone.warning,
      DeadlineUrgency.none => AtTone.neutral,
    };
    return AtCard(
      onTap: onTap,
      semanticLabel: '$title, $providerName, $deadlineLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AtTag(label: typeLabel, tone: AtTone.purple),
                    AtTag(label: trustLabel, tone: trustTone, icon: trustIcon),
                  ],
                ),
              ),
              _SaveButton(saved: saved, onTap: onSave, title: title),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AtTextStyles.cardTitle.copyWith(
              color: AtColors.ink,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            providerName,
            style: AtTextStyles.meta.copyWith(color: AtColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (valueLabel != null)
                Expanded(
                  child: _Fact(
                    icon: LucideIcons.wallet,
                    text: valueLabel!,
                    tone: AtTone.success,
                  ),
                ),
              Expanded(
                child: _Fact(
                  icon: LucideIcons.calendarClock,
                  text: deadlineLabel,
                  tone: urgent,
                ),
              ),
            ],
          ),
          if (locationLabel != null || trackingLabel != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (locationLabel != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: AtColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            locationLabel!,
                            style: AtTextStyles.meta.copyWith(
                              color: AtColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (trackingLabel != null)
                  AtStatusPill(label: trackingLabel!, tone: AtTone.success),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, required this.tone});

  final IconData icon;
  final String text;
  final AtTone tone;

  @override
  Widget build(BuildContext context) {
    final c = tone.colors;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: c.bg, borderRadius: AtRadii.tile),
      child: Row(
        children: [
          Icon(icon, size: 14, color: c.fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.metaSm.copyWith(
                color: c.strong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skill Labs item: source and delivery are always labelled ("Atarah Course", "Opens outside Atarah").
class LearningCard extends StatelessWidget {
  const LearningCard({
    super.key,
    required this.title,
    required this.meta,
    required this.typeLabel,
    required this.sourceLabel,
    this.sourceTone = AtTone.primary,
    this.icon = LucideIcons.graduationCap,
    this.progress,
    this.onTap,
  });

  final String title;
  final String meta;
  final String typeLabel;
  final String sourceLabel;
  final AtTone sourceTone;
  final IconData icon;

  /// 0..1; shown as a bar when set.
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      semanticLabel: '$title, $typeLabel, $sourceLabel',
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AtGradients.ctaSquare,
              borderRadius: AtRadii.tileLg,
            ),
            child: Icon(icon, color: AtColors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    AtTag(label: typeLabel, tone: AtTone.neutral),
                    AtTag(label: sourceLabel, tone: sourceTone),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  AtProgressBar(value: progress!, semanticLabel: title),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Marketplace listing card. The price string is formatted by the caller ("From KES 5,000").
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.sellerName,
    required this.priceLabel,
    this.imageUrl,
    this.rating,
    this.saved = false,
    this.onSave,
    this.onTap,
    this.categoryLabel,
  });

  final String title;
  final String sellerName;
  final String priceLabel;
  final String? imageUrl;
  final double? rating;
  final bool saved;
  final VoidCallback? onSave;
  final VoidCallback? onTap;
  final String? categoryLabel;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: '$title by $sellerName, $priceLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: imageUrl == null
                      ? const ColoredBox(
                          color: AtColors.softTile,
                          child: Center(
                            child: Icon(
                              LucideIcons.image,
                              color: AtColors.faint,
                            ),
                          ),
                        )
                      : Image.network(imageUrl!, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AtColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _SaveButton(saved: saved, onTap: onSave, title: title),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categoryLabel != null) ...[
                  AtTag(label: categoryLabel!, tone: AtTone.primary),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  sellerName,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priceLabel,
                        style: AtTextStyles.cardTitle.copyWith(
                          color: AtColors.primary,
                        ),
                      ),
                    ),
                    if (rating != null) ...[
                      const Icon(
                        LucideIcons.star,
                        size: 14,
                        color: AtColors.star,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: AtTextStyles.metaSm.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mentor in the directory.
class MentorCard extends StatelessWidget {
  const MentorCard({
    super.key,
    required this.name,
    required this.headline,
    required this.priceLabel,
    this.tags = const [],
    this.rating,
    this.reviewCount,
    this.nextAvailability,
    this.verified = false,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String headline;
  final String priceLabel;
  final List<String> tags;
  final double? rating;
  final int? reviewCount;
  final String? nextAvailability;
  final bool verified;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      semanticLabel: '$name, $headline, $priceLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AtAvatar(
                name: name,
                image: _img(imageUrl),
                size: 64,
                shape: AtAvatarShape.rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AtTextStyles.cardTitle.copyWith(
                              color: AtColors.ink,
                            ),
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          const AtVerifiedTick(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      style: AtTextStyles.meta.copyWith(color: AtColors.body),
                    ),
                    if (rating != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              size: 14,
                              color: AtColors.star,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              reviewCount == null
                                  ? rating!.toStringAsFixed(1)
                                  : '${rating!.toStringAsFixed(1)} ($reviewCount)',
                              style: AtTextStyles.metaSm.copyWith(
                                color: AtColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in tags) AtTag(label: t, tone: AtTone.primary),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Wrap rather than Row: at large text the price drops to its own line instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              if (nextAvailability != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendarClock,
                      size: 14,
                      color: AtColors.successFg,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        nextAvailability!,
                        style: AtTextStyles.metaSm.copyWith(
                          color: AtColors.successStrong,
                        ),
                      ),
                    ),
                  ],
                ),
              Text(
                priceLabel,
                style: AtTextStyles.cardTitle.copyWith(color: AtColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Community post. All counts and labels come from the caller.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.authorName,
    required this.metaLine,
    required this.typeLabel,
    required this.body,
    required this.likeCount,
    required this.replyCount,
    this.typeTone = AtTone.primary,
    this.authorImageUrl,
    this.imageUrl,
    this.liked = false,
    this.saved = false,
    this.authorVerified = false,
    this.onLike,
    this.onReply,
    this.onShare,
    this.onSave,
    this.onMore,
    this.onTap,
  });

  final String authorName;
  final String metaLine;
  final String typeLabel;
  final AtTone typeTone;
  final String body;
  final int likeCount;
  final int replyCount;
  final String? authorImageUrl;
  final String? imageUrl;
  final bool liked;
  final bool saved;
  final bool authorVerified;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                AtAvatar(
                  name: authorName,
                  image: _img(authorImageUrl),
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: AtColors.ink,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (authorVerified) ...[
                            const SizedBox(width: 6),
                            const AtVerifiedTick(size: 14),
                          ],
                        ],
                      ),
                      Text(
                        metaLine,
                        style: AtTextStyles.meta.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                AtTag(label: typeLabel, tone: typeTone),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              body,
              style: AtTextStyles.body.copyWith(color: AtColors.longForm),
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: AtRadii.card,
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(imageUrl!, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              _Action(
                icon: LucideIcons.heart,
                label: '$likeCount',
                semantic: liked
                    ? l10n.unlikeAction(likeCount)
                    : l10n.likeAction(likeCount),
                color: liked ? AtColors.pinkFg : AtColors.muted,
                onTap: onLike,
              ),
              _Action(
                icon: LucideIcons.messageCircle,
                label: '$replyCount',
                semantic: l10n.repliesAction(replyCount),
                onTap: onReply,
              ),
              _Action(
                icon: LucideIcons.share2,
                semantic: l10n.shareAction,
                onTap: onShare,
              ),
              const Spacer(),
              _Action(
                icon: saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                semantic: saved ? l10n.unsavePost : l10n.savePost,
                color: saved ? AtColors.primary : AtColors.muted,
                onTap: onSave,
              ),
              _Action(
                icon: LucideIcons.ellipsis,
                semantic: l10n.moreOptions,
                onTap: onMore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.semantic,
    this.label,
    this.color = AtColors.muted,
    this.onTap,
  });

  final IconData icon;
  final String? label;
  final String semantic;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AtTapTarget(
    onTap: onTap,
    semanticLabel: semantic,
    borderRadius: AtRadii.pill,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: color),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(label!, style: AtTextStyles.metaSm.copyWith(color: color)),
          ],
        ],
      ),
    ),
  );
}

/// Portfolio project tile.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.featured = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool featured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: '$title, $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: featured ? 1.7 : 1.2,
                  child: imageUrl == null
                      ? const ColoredBox(
                          color: AtColors.softTile,
                          child: Center(
                            child: Icon(
                              LucideIcons.image,
                              color: AtColors.faint,
                            ),
                          ),
                        )
                      : Image.network(imageUrl!, fit: BoxFit.cover),
                ),
              ),
              if (featured)
                Positioned(
                  top: 10,
                  left: 10,
                  child: AtTag(
                    label: AppLocalizations.of(context).featured,
                    tone: AtTone.primary,
                    solid: true,
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Creative Passport card. Trust pills appear only for real, current verifications.
class PassportCard extends StatelessWidget {
  const PassportCard({
    super.key,
    required this.passportNumber,
    required this.name,
    required this.disciplineLine,
    required this.locationLine,
    required this.memberSince,
    this.imageUrl,
    this.trustLabels = const [],
    this.onTap,
  });

  final String passportNumber;
  final String name;
  final String disciplineLine;
  final String locationLine;
  final String memberSince;
  final String? imageUrl;
  final List<String> trustLabels;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: '${l10n.creativePassport}: $passportNumber, $name',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AtGradients.darkCard,
          borderRadius: AtRadii.passport,
          boxShadow: AtShadows.darkCard,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AtRadii.passport,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.creativePassport,
                          style: AtTextStyles.label.copyWith(
                            color: AtColors.violet3,
                          ),
                        ),
                      ),
                      Text(
                        passportNumber,
                        style: AtTextStyles.metaSm.copyWith(
                          color: AtColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AtAvatar(
                        name: name,
                        image: _img(imageUrl),
                        size: 72,
                        shape: AtAvatarShape.rounded,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AtTextStyles.sectionTitle.copyWith(
                                color: AtColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              disciplineLine,
                              style: AtTextStyles.bodySm.copyWith(
                                color: const Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.85,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$locationLine · $memberSince',
                              style: AtTextStyles.meta.copyWith(
                                color: const Color.fromRGBO(255, 255, 255, 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (trustLabels.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in trustLabels)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.14),
                              borderRadius: AtRadii.pill,
                            ),
                            child: Text(
                              t,
                              style: AtTextStyles.chipSm.copyWith(
                                color: AtColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A skill with its 4-segment level bar and verification state.
class SkillCard extends StatelessWidget {
  const SkillCard({
    super.key,
    required this.name,
    required this.level,
    required this.levelLabel,
    required this.verification,
    this.onImprove,
    this.onFindOpportunities,
    this.onVerify,
  });

  final String name;

  /// 1..4
  final int level;
  final String levelLabel;
  final AtVerification verification;
  final VoidCallback? onImprove;
  final VoidCallback? onFindOpportunities;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
              ),
              AtVerificationBadge(status: verification),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: '$levelLabel, level $level of 4',
            excludeSemantics: true,
            child: Row(
              children: [
                for (var i = 1; i <= 4; i++) ...[
                  if (i > 1) const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= level
                            ? AtColors.primary
                            : AtColors.progressTrack,
                        borderRadius: AtRadii.pill,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                Text(
                  levelLabel,
                  style: AtTextStyles.metaSm.copyWith(color: AtColors.muted),
                ),
              ],
            ),
          ),
          if (onImprove != null ||
              onFindOpportunities != null ||
              onVerify != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                if (onImprove != null)
                  AtButton(
                    label: l10n.improveSkill,
                    variant: AtButtonVariant.tertiary,
                    size: AtButtonSize.sm,
                    fullWidth: false,
                    onPressed: onImprove,
                  ),
                if (onFindOpportunities != null)
                  AtButton(
                    label: l10n.findOpportunities,
                    variant: AtButtonVariant.tertiary,
                    size: AtButtonSize.sm,
                    fullWidth: false,
                    onPressed: onFindOpportunities,
                  ),
                if (onVerify != null)
                  AtButton(
                    label: l10n.verifyAction,
                    variant: AtButtonVariant.tertiary,
                    size: AtButtonSize.sm,
                    fullWidth: false,
                    onPressed: onVerify,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Community group with a Join / Joined toggle.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.name,
    required this.memberCountLabel,
    required this.typeLabel,
    required this.joined,
    required this.onToggle,
    this.icon = LucideIcons.users,
    this.onTap,
  });

  final String name;
  final String memberCountLabel;
  final String typeLabel;
  final bool joined;
  final VoidCallback? onToggle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      onTap: onTap,
      semanticLabel: '$name, $memberCountLabel',
      child: Row(
        children: [
          AtIconTile(icon: icon, size: 48, tone: AtTone.pink),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeLabel · $memberCountLabel',
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ],
            ),
          ),
          AtButton(
            label: joined ? l10n.joinedAction : l10n.joinAction,
            size: AtButtonSize.sm,
            fullWidth: false,
            variant: joined
                ? AtButtonVariant.secondary
                : AtButtonVariant.primary,
            icon: joined ? LucideIcons.check : null,
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

/// A notification row. Unread rows are tinted and carry a dot (colour is not the only cue: the dot is announced).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    this.tone = AtTone.primary,
    this.unread = false,
    this.onTap,
  });

  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final AtTone tone;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label:
          '${unread ? '${l10n.unreadPrefix} ' : ''}$title. $body. $timeLabel',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: unread ? AtColors.tint3 : AtColors.white,
        borderRadius: AtRadii.cardLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AtRadii.cardLg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtIconTile(icon: icon, tone: tone, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AtTextStyles.cardTitle.copyWith(
                          color: AtColors.ink,
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: AtTextStyles.bodySm.copyWith(
                          color: AtColors.body,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: AtTextStyles.meta.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(top: 6, left: 8),
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AtColors.primary,
                      shape: BoxShape.circle,
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

/// One saved item with its type label and an unsave action.
class SavedItemRow extends StatelessWidget {
  const SavedItemRow({
    super.key,
    required this.typeLabel,
    required this.title,
    required this.meta,
    required this.icon,
    this.tone = AtTone.primary,
    this.onTap,
    this.onUnsave,
  });

  final String typeLabel;
  final String title;
  final String meta;
  final IconData icon;
  final AtTone tone;
  final VoidCallback? onTap;
  final VoidCallback? onUnsave;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      semanticLabel: '$typeLabel: $title',
      child: Row(
        children: [
          AtIconTile(icon: icon, tone: tone, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel.toUpperCase(),
                  style: AtTextStyles.label.copyWith(color: tone.colors.strong),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                Text(
                  meta,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ],
            ),
          ),
          AtTapTarget(
            onTap: onUnsave,
            semanticLabel: AppLocalizations.of(context).unsaveItem(title),
            child: const Icon(
              LucideIcons.bookmarkCheck,
              size: 20,
              color: AtColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
