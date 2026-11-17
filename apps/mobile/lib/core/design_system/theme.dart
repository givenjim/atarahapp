import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.g.dart';

/// Reads the active appearance's colours: `context.at.primary`, `context.at.surface`,
/// `context.at.shadowCard`, `context.at.darkCardGradient`.
///
/// Falls back to the set matching [Theme.brightness] when a test wraps widgets in a plain
/// [ThemeData] without the [AtColors] extension, so it never throws.
extension AtThemeContext on BuildContext {
  AtColors get at {
    final theme = Theme.of(this);
    return theme.extension<AtColors>() ??
        (theme.brightness == Brightness.dark ? AtColors.dark : AtColors.light);
  }
}

/// Semantic colour pairs used by tags, status pills, icon tiles and banners (Master Prompt 8.2).
enum AtTone { primary, violet, indigo, success, warning, coral, amber, neutral }

/// Resolved colours for an [AtTone] in one appearance.
class AtToneColors {
  const AtToneColors({
    required this.bg,
    required this.fg,
    required this.strong,
  });

  final Color bg;

  /// Icon and accent colour. Never use it for small text.
  final Color fg;

  /// Text colour that keeps 4.5:1 contrast on [bg].
  final Color strong;
}

extension AtToneX on AtTone {
  /// Resolves this tone for the active appearance: `tone.colorsOf(context)`.
  AtToneColors colorsOf(BuildContext context) => context.at.tone(this);
}

/// Page backgrounds carry a soft radial wash in the top-right, tinted per area.
enum AtWash { standard, opportunities, learning, community, settings }

extension AtWashX on AtWash {
  /// Resolves this wash for the active appearance: `wash.colorOf(context)`.
  Color colorOf(BuildContext context) => context.at.wash(this);
}

/// Resolvers that need the full colour set (use them when you already hold an [AtColors]).
extension AtColorsResolvers on AtColors {
  AtToneColors tone(AtTone tone) => switch (tone) {
    AtTone.primary => AtToneColors(
      bg: primaryTint,
      fg: primary,
      strong: primary,
    ),
    AtTone.violet => AtToneColors(
      bg: violetSurface,
      fg: primary,
      strong: primary,
    ),
    AtTone.indigo => AtToneColors(
      bg: indigoSurface,
      fg: primary,
      strong: primary,
    ),
    AtTone.success => AtToneColors(
      bg: successSurface,
      fg: successIcon,
      strong: successStrong,
    ),
    AtTone.warning => AtToneColors(
      bg: tangerineSurface,
      fg: tangerine,
      strong: tangerineStrong,
    ),
    AtTone.coral => AtToneColors(
      bg: coralSurface,
      fg: coral,
      strong: coralStrong,
    ),
    AtTone.amber => AtToneColors(
      bg: amberSurface,
      fg: tangerine,
      strong: amberStrong,
    ),
    AtTone.neutral => AtToneColors(
      bg: neutralSurface,
      fg: neutralText,
      strong: neutralText,
    ),
  };

  Color wash(AtWash wash) => switch (wash) {
    AtWash.standard => washDefault,
    AtWash.opportunities => washOpportunities,
    AtWash.learning => washLearning,
    AtWash.community => washCommunity,
    AtWash.settings => washSettings,
  };

  /// Whether this is the dark set.
  bool get isDark => background == AtColors.dark.background;
}

/// Material 3 themes built from the design tokens. Both carry the [AtColors] extension.
abstract final class AtTheme {
  static final ThemeData light = _build(AtColors.light, Brightness.light);
  static final ThemeData dark = _build(AtColors.dark, Brightness.dark);

  static ThemeData _build(AtColors c, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AtBrand.indigo,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: brightness == Brightness.dark ? AtBrand.midnight : c.white,
          secondary: c.primaryLight,
          surface: c.surface,
          onSurface: c.ink,
          error: c.coralStrong,
          outline: c.inputBorder,
          outlineVariant: c.cardBorder,
        );

    const textTheme = TextTheme(
      displayLarge: AtTextStyles.tabTitle,
      headlineLarge: AtTextStyles.subTitle,
      headlineMedium: AtTextStyles.detailTitle,
      titleLarge: AtTextStyles.sectionTitle,
      titleMedium: AtTextStyles.cardTitle,
      bodyLarge: AtTextStyles.bodyLg,
      bodyMedium: AtTextStyles.body,
      bodySmall: AtTextStyles.meta,
      labelLarge: AtTextStyles.button,
      labelMedium: AtTextStyles.chip,
      labelSmall: AtTextStyles.label,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[c],
      fontFamily: AtTextStyles.fontFamily,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme.apply(bodyColor: c.ink, displayColor: c.ink),
      dividerColor: c.divider,
      splashFactory: InkRipple.splashFactory,
      focusColor: c.focusRing,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: c.ink,
        systemOverlayStyle: overlayStyle(brightness),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        modalBarrierColor: c.scrimSheet,
        shape: const RoundedRectangleBorder(borderRadius: AtRadii.sheetTop),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        barrierColor: c.scrimModal,
        shape: const RoundedRectangleBorder(borderRadius: AtRadii.modal),
      ),
      cardColor: c.surface,
      visualDensity: VisualDensity.standard,
    );
  }

  /// Status and navigation bar styles for an appearance (transparent bars, matching icons).
  /// Dark brand screens (splash) wrap their subtree in `AnnotatedRegion` with
  /// [overlayStyle] for [Brightness.dark].
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: dark
          ? Brightness.light
          : Brightness.dark,
    );
  }
}
