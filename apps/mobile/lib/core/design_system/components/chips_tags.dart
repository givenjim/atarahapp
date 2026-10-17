import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';
import 'at_tap_target.dart';

enum AtChipKind { selectable, removable, dropdown }

/// Chip for filters, skills and choices. Selected chips are filled; removable chips show an ×;
/// dropdown chips show a chevron (filter groups).
class AtChip extends StatelessWidget {
  const AtChip({
    super.key,
    required this.label,
    this.kind = AtChipKind.selectable,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.icon,
    this.removeSemanticLabel,
  });

  final String label;
  final AtChipKind kind;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final IconData? icon;
  final String? removeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final on = selected || kind == AtChipKind.removable;
    final bg = on ? AtColors.primary : AtColors.white;
    final fg = on ? AtColors.white : AtColors.ink;

    final chip = AnimatedContainer(
      duration: atDuration(context, AtMotion.fast),
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AtRadii.pill,
        border: Border.all(color: on ? AtColors.primary : AtColors.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ] else if (selected && kind == AtChipKind.selectable) ...[
            Icon(LucideIcons.check, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.chip.copyWith(color: fg),
            ),
          ),
          if (kind == AtChipKind.dropdown) ...[
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronDown, size: 14, color: fg),
          ],
          if (kind == AtChipKind.removable) ...[
            const SizedBox(width: 4),
            AtTapTarget(
              minSize: 32,
              semanticLabel:
                  removeSemanticLabel ?? AppLocalizations.of(context).remove,
              onTap: onRemove,
              child: Icon(LucideIcons.x, size: 14, color: fg),
            ),
          ],
        ],
      ),
    );

    // The visible chip stays 36 high; the hit area is 48.
    return Semantics(
      button: kind != AtChipKind.removable,
      selected: selected,
      label: label,
      excludeSemantics: kind != AtChipKind.removable,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AtSizes.touchTarget),
          child: Center(widthFactor: 1, heightFactor: 1, child: chip),
        ),
      ),
    );
  }
}

/// Small label (type, source, level). Never the only carrier of meaning: it always has text.
class AtTag extends StatelessWidget {
  const AtTag({
    super.key,
    required this.label,
    this.tone = AtTone.neutral,
    this.icon,
    this.solid = false,
  });

  final String label;
  final AtTone tone;
  final IconData? icon;

  /// Solid primary fill (used over imagery).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = tone.colors;
    final bg = solid ? AtColors.primary : c.bg;
    final fg = solid ? AtColors.white : c.strong;
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AtRadii.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.chipSm.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status with a leading dot ("In progress", "Under review", "Published"). Text carries the meaning, colour supports it.
class AtStatusPill extends StatelessWidget {
  const AtStatusPill({
    super.key,
    required this.label,
    this.tone = AtTone.neutral,
    this.showDot = true,
  });

  final String label;
  final AtTone tone;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final c = tone.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.bg, borderRadius: AtRadii.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.chipSm.copyWith(color: c.strong),
            ),
          ),
        ],
      ),
    );
  }
}

/// The small verified tick shown beside a name. Only render it for a real, current verification.
class AtVerifiedTick extends StatelessWidget {
  const AtVerifiedTick({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).verified,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AtColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.check,
          size: size * 0.62,
          color: AtColors.white,
        ),
      ),
    );
  }
}

/// Verification state shown as a badge. Mirrors the backend `VerificationStatus`, where a skill with no
/// case is "Self-declared" and SUBMITTED/UNDER_REVIEW both read "Under review".
enum AtVerification {
  selfDeclared,
  underReview,
  verified,
  rejected,
  expired,
  revoked,
}

class AtVerificationBadge extends StatelessWidget {
  const AtVerificationBadge({super.key, required this.status});

  final AtVerification status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, tone, icon) = switch (status) {
      AtVerification.verified => (
        l10n.verifiedByAtarah,
        AtTone.primary,
        LucideIcons.badgeCheck,
      ),
      AtVerification.underReview => (
        l10n.underReview,
        AtTone.amber,
        LucideIcons.clock,
      ),
      AtVerification.selfDeclared => (l10n.selfDeclared, AtTone.neutral, null),
      AtVerification.rejected => (
        l10n.verificationRejected,
        AtTone.pink,
        LucideIcons.circleX,
      ),
      AtVerification.expired => (
        l10n.verificationExpired,
        AtTone.warning,
        LucideIcons.clockAlert,
      ),
      AtVerification.revoked => (
        l10n.verificationRevoked,
        AtTone.pink,
        LucideIcons.ban,
      ),
    };
    return AtTag(label: label, tone: tone, icon: icon);
  }
}
