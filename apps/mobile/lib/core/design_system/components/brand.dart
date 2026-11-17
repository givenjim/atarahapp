import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';

/// Which logo artwork to show (Master Prompt 8.4).
enum AtLogoVariant {
  /// Wordmark with the brand line. Only at 300 px wide or more.
  primary(300, 'atarah-logo-primary'),

  /// Wordmark without the brand line. 120 px wide or more.
  noBrandLine(120, 'atarah-logo-notagline'),

  /// The "A" symbol alone. 20 px wide or more.
  symbol(20, 'atarah-symbol');

  const AtLogoVariant(this.minWidth, this.assetBase);

  final double minWidth;
  final String assetBase;
}

/// Colour treatment of the logo.
enum AtLogoStyle {
  /// Full colour on light, reversed on dark (the default for normal screens).
  automatic,

  /// Always reversed: use on the Midnight gradient (splash) and other dark brand surfaces.
  reversed,

  /// Single white version (for example the symbol on the Passport card).
  monoWhite,

  /// Single dark version.
  monoDark,
}

/// The Atarah logo, from the logo pack SVGs in `assets/brand/`. Never recoloured or redrawn.
///
/// Give it a [width]; the height follows the artwork. Placements (Master Prompt 8.4):
/// splash 300 reversed primary, welcome 140 and home 126 no-brand-line, symbol 20 and 26.
/// Minimum widths are asserted in debug builds.
class AtLogo extends StatelessWidget {
  AtLogo({
    super.key,
    this.variant = AtLogoVariant.noBrandLine,
    required this.width,
    this.style = AtLogoStyle.automatic,
  }) : assert(
         width >= variant.minWidth,
         'AtLogo ${variant.name} must be at least ${variant.minWidth}px wide (got $width). '
         'Master Prompt 8.4.',
       );

  const AtLogo.symbol({
    super.key,
    required this.width,
    this.style = AtLogoStyle.automatic,
  }) : variant = AtLogoVariant.symbol,
       assert(
         width >= 20,
         'AtLogo symbol must be at least 20px wide (Master Prompt 8.4).',
       );

  final AtLogoVariant variant;
  final double width;
  final AtLogoStyle style;

  /// The asset file for a variant, style and appearance. The symbol keeps its gradients in
  /// both appearances, so its colour and reversed artwork are the same drawing.
  static String assetFor(
    AtLogoVariant variant,
    AtLogoStyle style,
    Brightness brightness,
  ) {
    final suffix = switch (style) {
      AtLogoStyle.automatic =>
        brightness == Brightness.dark && variant != AtLogoVariant.symbol
            ? 'reversed'
            : 'color',
      AtLogoStyle.reversed => 'reversed',
      AtLogoStyle.monoWhite => 'mono-white',
      AtLogoStyle.monoDark => 'mono-dark',
    };
    return 'assets/brand/${variant.assetBase}-$suffix.svg';
  }

  @override
  Widget build(BuildContext context) {
    assert(
      width >= variant.minWidth,
      'AtLogo ${variant.name} must be at least ${variant.minWidth}px wide.',
    );
    final asset = assetFor(variant, style, Theme.of(context).brightness);
    return Semantics(
      label: AppLocalizations.of(context).appName,
      image: true,
      excludeSemantics: true,
      child: SvgPicture.asset(asset, width: width, fit: BoxFit.contain),
    );
  }
}

/// The brand ring motif (Master Prompt 8.1): a 240 px Coral to Tangerine gradient circle
/// masked to a ring, sitting 70 px off the top-right corner, low emphasis, behind content.
///
/// Place it as a child of a [Stack] inside a clipped container (it positions itself).
class AtBrandRing extends StatelessWidget {
  const AtBrandRing({
    super.key,
    this.diameter = 240,
    this.offset = 70,
    this.opacity = 0.22,
  });

  final double diameter;

  /// How far the ring sits outside the top and right edges.
  final double offset;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -offset,
      right: -offset,
      width: diameter,
      height: diameter,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: const CustomPaint(painter: AtBrandRingPainter()),
          ),
        ),
      ),
    );
  }
}

/// Paints the ring: the circle is clear inside 57.5% of the farthest-corner radius
/// (`radial-gradient(circle, transparent 57%, #000 58%)`) and filled outside it.
class AtBrandRingPainter extends CustomPainter {
  const AtBrandRingPainter();

  /// Midpoint of the 57% to 58% mask edge.
  static const double innerFraction = 0.575;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = size.shortestSide / 2;
    // The mask radius is measured to the farthest corner of the box.
    final inner = innerFraction * outer * math.sqrt2;
    final thickness = outer - inner;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true
      ..shader = AtGradients.brandRing.createShader(rect);
    canvas.drawCircle(rect.center, inner + thickness / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AtBrandRingPainter oldDelegate) => false;
}

/// Atarah Pro / Premium pill: Coral to Tangerine gradient, white text, crown icon.
class AtProPill extends StatelessWidget {
  const AtProPill({super.key, this.label, this.compact = false});

  /// Defaults to the localised "Pro".
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.at;
    final text = label ?? AppLocalizations.of(context).proPillLabel;
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 3 : 5,
        ),
        decoration: const BoxDecoration(
          gradient: AtGradients.pro,
          borderRadius: AtRadii.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.crown, size: compact ? 11 : 13, color: c.white),
            const SizedBox(width: 4),
            Text(
              text,
              style: AtTextStyles.chipSm.copyWith(
                color: c.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
