import 'package:flutter/material.dart';

import '../tokens.g.dart';

/// Guarantees a minimum 48×48 touch target around a smaller visual, without growing the visual itself.
class AtTapTarget extends StatelessWidget {
  const AtTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticsRole,
    this.minSize = AtSizes.touchTarget,
    this.borderRadius = AtRadii.pill,
    this.enabled = true,
    this.excludeSemantics = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? semanticsRole;
  final double minSize;
  final BorderRadius borderRadius;
  final bool enabled;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
    content = Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: active ? onTap : null,
        borderRadius: borderRadius,
        containedInkWell: false,
        radius: minSize / 2,
        highlightShape: BoxShape.circle,
        child: content,
      ),
    );
    if (semanticLabel == null) return content;
    return Semantics(
      button: true,
      enabled: active,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: active ? onTap : null,
      child: content,
    );
  }
}

/// True when the user asked the platform to reduce motion.
bool atReduceMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Animation duration that collapses to zero under "reduce motion".
Duration atDuration(BuildContext context, Duration d) =>
    atReduceMotion(context) ? Duration.zero : d;

/// A fixed extent (a grid tile or a carousel row) that grows with the platform text size, so text at 200% fits.
/// [textShare] is the part of [base] that is text; it grows with the scale, the rest (pictures, padding) does not.
double atScaledExtent(
  BuildContext context,
  double base, {
  double textShare = 0.35,
}) {
  final scale = MediaQuery.textScalerOf(context).scale(1.0);
  return base * (1 + (scale < 1 ? 0 : scale - 1) * textShare);
}
