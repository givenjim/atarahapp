import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';
import 'brand.dart';
import 'buttons.dart';

/// White card with the standard border and soft shadow. Tappable when [onTap] is set.
class AtCard extends StatelessWidget {
  const AtCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AtSpacing.cardPadding),
    this.radius = AtRadii.cardLg,
    this.color,
    this.border = true,
    this.shadow = true,
    this.semanticLabel,
    this.labelReplacesContent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;

  /// Defaults to the theme surface colour.
  final Color? color;
  final bool border;
  final bool shadow;
  final String? semanticLabel;

  /// With a [semanticLabel]: hide the card's own text and controls from screen readers (a leaf card).
  final bool labelReplacesContent;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(padding: padding, child: child);
    // A tappable card is always a 48 dp target, however little it holds.
    final body = onTap == null
        ? padded
        : ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AtSizes.touchTarget),
            child: Center(widthFactor: 1, child: padded),
          );
    final deco = BoxDecoration(
      color: color ?? context.at.surface,
      borderRadius: radius,
      border: border ? Border.all(color: context.at.cardBorder) : null,
      boxShadow: shadow ? context.at.shadowCard : null,
    );
    final card = DecoratedBox(
      decoration: deco,
      child: onTap == null
          ? body
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, borderRadius: radius, child: body),
            ),
    );
    if (onTap == null) return card;
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      // For a leaf card, the explicit label replaces the card's own text so a screen reader does not read it
      // twice. A card that holds its own controls (a bookmark) keeps them reachable, so this stays off there.
      excludeSemantics: semanticLabel != null && labelReplacesContent,
      onTap: semanticLabel != null && labelReplacesContent ? onTap : null,
      child: card,
    );
  }
}

/// Dark hero card (profile completion, continue learning).
class AtDarkCard extends StatelessWidget {
  const AtDarkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.radius = AtRadii.panelLg,
    this.ring = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;

  /// Draws the [AtBrandRing] motif behind the content, off the top-right corner.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    final content = onTap == null
        ? body
        : Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap, borderRadius: radius, child: body),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.at.darkCardGradient,
        borderRadius: radius,
        boxShadow: context.at.shadowDarkCard,
      ),
      child: ring
          ? ClipRRect(
              borderRadius: radius,
              child: Stack(children: [const AtBrandRing(), content]),
            )
          : content,
    );
  }
}

/// Section title with an optional "See all".
class AtSectionHeader extends StatelessWidget {
  const AtSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.compact = false,
    this.trailing,
    this.seeAllLabel,
  });

  final String title;
  final VoidCallback? onSeeAll;

  /// Replaces "See all", e.g. "See all 12".
  final String? seeAllLabel;

  /// Smaller title used inside detail screens (17 instead of 20).
  final bool compact;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style:
                  (compact
                          ? AtTextStyles.sectionTitleSm
                          : AtTextStyles.sectionTitle)
                      .copyWith(color: context.at.ink),
            ),
          ),
        ),
        ?trailing,
        if (onSeeAll != null)
          AtButton(
            label: seeAllLabel ?? l10n.seeAll,
            semanticLabel: '${seeAllLabel ?? l10n.seeAll}: $title',
            onPressed: onSeeAll,
            variant: AtButtonVariant.tertiary,
            size: AtButtonSize.sm,
            fullWidth: false,
          ),
      ],
    );
  }
}

/// Screen top bar: optional back button, title, trailing actions. Padding 6 / 14.
class AtTopBar extends StatelessWidget {
  const AtTopBar({
    super.key,
    this.title,
    this.onBack,
    this.backSemanticLabel,
    this.actions = const [],
    this.centerTitle = true,
  });

  final String? title;
  final VoidCallback? onBack;
  final String? backSemanticLabel;
  final List<Widget> actions;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AtSpacing.topBarV,
        horizontal: AtSpacing.topBarH,
      ),
      child: Row(
        children: [
          if (onBack != null)
            AtIconButton(
              icon: LucideIcons.chevronLeft,
              semanticLabel: backSemanticLabel ?? l10n.back,
              onPressed: onBack,
            )
          else
            const SizedBox(width: AtSizes.backButton),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      textAlign: centerTitle
                          ? TextAlign.center
                          : TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.sectionTitleSm.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
          ),
          if (actions.isEmpty)
            const SizedBox(width: AtSizes.backButton)
          else
            Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );
  }
}

/// Square icon tile used by list rows, tiles and empty states.
class AtIconTile extends StatelessWidget {
  const AtIconTile({
    super.key,
    required this.icon,
    this.tone = AtTone.primary,
    this.size = 44,
    this.radius = AtRadii.tileLg,
  });

  final IconData icon;
  final AtTone tone;
  final double size;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final c = tone.colorsOf(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.bg, borderRadius: radius),
      child: Icon(icon, size: size * 0.46, color: c.fg),
    );
  }
}

/// Settings-style row: icon tile, title, optional subtitle, trailing widget or chevron.
class AtListRow extends StatelessWidget {
  const AtListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tone = AtTone.primary,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.destructive = false,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final AtTone tone;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool destructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? context.at.coralStrong : context.at.ink;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (icon != null) ...[
              AtIconTile(
                icon: icon!,
                tone: destructive ? AtTone.coral : tone,
                size: 40,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (trailing == null && showChevron && onTap != null) ...[
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, size: 18, color: context.at.faint),
            ],
          ],
        ),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        onTap == null
            ? row
            : Semantics(
                button: true,
                label: [title, ?subtitle].join(', '),
                excludeSemantics: true,
                onTap: onTap,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: AtRadii.tileLg,
                  child: row,
                ),
              ),
        if (showDivider) Divider(height: 1, color: context.at.divider),
      ],
    );
    return Material(type: MaterialType.transparency, child: content);
  }
}

/// A figure with a label (in progress / completed / hours this month).
class AtStatTile extends StatelessWidget {
  const AtStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.tone = AtTone.primary,
  });

  final String value;
  final String label;
  final IconData? icon;
  final AtTone tone;

  @override
  Widget build(BuildContext context) {
    final c = tone.colorsOf(context);
    return Semantics(
      container: true,
      label: '$value $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.at.softTile,
          borderRadius: AtRadii.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: c.fg),
              const SizedBox(height: 8),
            ],
            Text(
              value,
              style: AtTextStyles.subTitle.copyWith(color: context.at.ink),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AtTextStyles.meta.copyWith(color: context.at.muted),
            ),
          ],
        ),
      ),
    );
  }
}

enum AtTimelineState { done, current, upcoming }

class AtTimelineItem {
  const AtTimelineItem({
    required this.title,
    this.subtitle,
    this.state = AtTimelineState.upcoming,
  });

  final String title;
  final String? subtitle;
  final AtTimelineState state;
}

/// Vertical timeline (verification progress, experience).
class AtTimeline extends StatelessWidget {
  const AtTimeline({super.key, required this.items});

  final List<AtTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      _dot(context, items[i].state),
                      if (i < items.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: items[i].state == AtTimelineState.done
                                ? context.at.primaryLight
                                : context.at.progressTrack,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].title,
                          style: AtTextStyles.cardTitle.copyWith(
                            color: items[i].state == AtTimelineState.upcoming
                                ? context.at.muted
                                : context.at.ink,
                          ),
                        ),
                        if (items[i].subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            items[i].subtitle!,
                            style: AtTextStyles.meta.copyWith(
                              color: context.at.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dot(BuildContext context, AtTimelineState s) => switch (s) {
    AtTimelineState.done => Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.at.successSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(LucideIcons.check, size: 14, color: context.at.successIcon),
    ),
    AtTimelineState.current => Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.at.primaryFill,
        shape: BoxShape.circle,
      ),
      child: Icon(LucideIcons.play, size: 11, color: context.at.white),
    ),
    AtTimelineState.upcoming => Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.at.surface,
        shape: BoxShape.circle,
        border: Border.all(color: context.at.secondaryBorder, width: 1.5),
      ),
    ),
  };
}
