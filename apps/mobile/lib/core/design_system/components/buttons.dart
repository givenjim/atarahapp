import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens.g.dart';
import 'at_tap_target.dart';

enum AtButtonVariant { primary, secondary, tertiary, destructive }

enum AtButtonSize { lg, md, sm }

/// Primary gradient, secondary outline, tertiary text and destructive buttons (heights 54 / 48 / 34).
/// Supports loading and disabled states. While loading the button ignores taps and announces itself as busy.
class AtButton extends StatelessWidget {
  const AtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AtButtonVariant.primary,
    this.size = AtButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
    this.semanticLabel,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AtButtonVariant variant;
  final AtButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;
  final String? semanticLabel;

  double get _height => switch (size) {
    AtButtonSize.lg => AtSizes.buttonLg,
    AtButtonSize.md => AtSizes.buttonMd,
    AtButtonSize.sm => AtSizes.buttonSm,
  };

  TextStyle get _textStyle =>
      size == AtButtonSize.sm ? AtTextStyles.buttonSm : AtTextStyles.button;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final (Color fg, BoxDecoration deco) = _style(disabled);

    final iconSize = size == AtButtonSize.sm ? 16.0 : 18.0;
    final Widget content = loading
        ? SizedBox(
            width: iconSize + 2,
            height: iconSize + 2,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _textStyle.copyWith(color: fg),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: iconSize, color: fg),
              ],
            ],
          );

    // The visual height follows the spec (34 for small); the tap target never drops below 48.
    final visual = AnimatedContainer(
      duration: atDuration(context, AtMotion.fast),
      height: _height,
      constraints: BoxConstraints(minWidth: size == AtButtonSize.sm ? 64 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: size == AtButtonSize.sm ? 16 : 24,
      ),
      decoration: deco,
      alignment: Alignment.center,
      child: content,
    );

    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        borderRadius: AtRadii.pill,
        child: visual,
      ),
    );

    final sized = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AtSizes.touchTarget),
      child: Align(
        widthFactor: fullWidth ? null : 1,
        heightFactor: 1,
        child: fullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel ?? label,
      value: loading ? 'busy' : null,
      excludeSemantics: true,
      onTap: _enabled ? onPressed : null,
      child: sized,
    );
  }

  (Color, BoxDecoration) _style(bool disabled) {
    if (disabled) {
      return (
        AtColors.disabledText,
        BoxDecoration(
          color: variant == AtButtonVariant.tertiary
              ? null
              : AtColors.disabledFill,
          borderRadius: AtRadii.pill,
        ),
      );
    }
    return switch (variant) {
      AtButtonVariant.primary => (
        AtColors.white,
        const BoxDecoration(
          gradient: AtGradients.cta,
          borderRadius: AtRadii.pill,
          boxShadow: AtShadows.cta,
        ),
      ),
      AtButtonVariant.secondary => (
        AtColors.primary,
        BoxDecoration(
          color: AtColors.white,
          borderRadius: AtRadii.pill,
          border: Border.all(color: AtColors.secondaryBorder, width: 1.5),
        ),
      ),
      AtButtonVariant.tertiary => (
        AtColors.primary,
        const BoxDecoration(borderRadius: AtRadii.pill),
      ),
      AtButtonVariant.destructive => (
        AtColors.pinkStrong,
        const BoxDecoration(color: AtColors.pinkBg, borderRadius: AtRadii.pill),
      ),
    };
  }
}

enum AtIconButtonVariant {
  /// 44×44, radius 14, bordered. The standard back button.
  back,

  /// White circle with a soft shadow, for floating actions.
  floating,

  /// Translucent over imagery.
  glass,

  /// 44×44 bordered filter button with an optional active dot.
  filter,

  /// Gradient square (135°), e.g. compose.
  gradient,
}

/// Icon-only button. A semantic label is required: icon buttons are unreadable to screen readers otherwise.
class AtIconButton extends StatelessWidget {
  const AtIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = AtIconButtonVariant.back,
    this.showDot = false,
    this.badge,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AtIconButtonVariant variant;

  /// Filter variant: show a dot when filters are active.
  final bool showDot;

  /// Optional count badge (e.g. unread notifications).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    const size = AtSizes.backButton;
    final disabled = onPressed == null;

    Widget visual = switch (variant) {
      AtIconButtonVariant.back || AtIconButtonVariant.filter => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AtColors.white,
          borderRadius: AtRadii.backButton,
          border: Border.all(color: AtColors.cardBorder),
        ),
        child: Icon(
          icon,
          size: 20,
          color: disabled ? AtColors.faint : AtColors.ink,
        ),
      ),
      AtIconButtonVariant.floating => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AtColors.white,
          shape: BoxShape.circle,
          boxShadow: AtShadows.floating,
        ),
        child: Icon(icon, size: 20, color: AtColors.ink),
      ),
      AtIconButtonVariant.glass => ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: size,
            height: size,
            color: const Color.fromRGBO(255, 255, 255, 0.28),
            child: Icon(icon, size: 20, color: AtColors.white),
          ),
        ),
      ),
      AtIconButtonVariant.gradient => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: AtGradients.ctaSquare,
          borderRadius: AtRadii.input,
          boxShadow: AtShadows.cta,
        ),
        child: Icon(icon, size: 20, color: AtColors.white),
      ),
    };

    if (showDot || badge != null) {
      visual = Stack(
        clipBehavior: Clip.none,
        children: [
          visual,
          Positioned(
            top: -2,
            right: -2,
            child: badge != null && badge! > 0
                ? Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AtColors.pinkFg,
                      borderRadius: AtRadii.pill,
                      border: Border.all(color: AtColors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      style: AtTextStyles.chipSm.copyWith(
                        color: AtColors.white,
                        fontSize: 10,
                      ),
                    ),
                  )
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AtColors.pinkFg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AtColors.white, width: 2),
                    ),
                  ),
          ),
        ],
      );
    }

    return AtTapTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      enabled: !disabled,
      child: visual,
    );
  }
}
