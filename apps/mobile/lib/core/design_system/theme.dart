import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// Semantic colour pairs used by tags, status pills, icon tiles and banners.
enum AtTone { primary, success, warning, pink, info, purple, amber, neutral }

/// Resolved colours for an [AtTone].
class AtToneColors {
  const AtToneColors({
    required this.bg,
    required this.fg,
    required this.strong,
  });

  final Color bg;
  final Color fg;

  /// Darker text colour that keeps 4.5:1 contrast on [bg].
  final Color strong;
}

extension AtToneX on AtTone {
  AtToneColors get colors => switch (this) {
    AtTone.primary => const AtToneColors(
      bg: AtColors.tint1,
      fg: AtColors.primary,
      strong: AtColors.primary,
    ),
    AtTone.success => const AtToneColors(
      bg: AtColors.successBg,
      fg: AtColors.successFg,
      strong: AtColors.successStrong,
    ),
    AtTone.warning => const AtToneColors(
      bg: AtColors.warningBg,
      fg: AtColors.warningFg,
      strong: AtColors.warningStrong,
    ),
    AtTone.pink => const AtToneColors(
      bg: AtColors.pinkBg,
      fg: AtColors.pinkFg,
      strong: AtColors.pinkStrong,
    ),
    AtTone.info => const AtToneColors(
      bg: AtColors.infoBg,
      fg: AtColors.infoFg,
      strong: AtColors.infoStrong,
    ),
    AtTone.purple => const AtToneColors(
      bg: AtColors.purpleBg,
      fg: AtColors.purpleFg,
      strong: AtColors.purpleStrong,
    ),
    AtTone.amber => const AtToneColors(
      bg: AtColors.amberBg,
      fg: AtColors.amberFg,
      strong: AtColors.amberStrong,
    ),
    AtTone.neutral => const AtToneColors(
      bg: AtColors.neutralBg,
      fg: AtColors.neutralFg,
      strong: AtColors.neutralStrong,
    ),
  };
}

/// Page backgrounds are white with a soft radial wash in the top-right, tinted per area.
enum AtWash { standard, opportunities, learning, community, settings }

extension AtWashX on AtWash {
  Color get color => switch (this) {
    AtWash.standard => AtColors.washDefault,
    AtWash.opportunities => AtColors.washOpportunities,
    AtWash.learning => AtColors.washLearning,
    AtWash.community => AtColors.washCommunity,
    AtWash.settings => AtColors.washSettings,
  };
}

/// Material 3 theme built from the design tokens. Light only for now.
abstract final class AtTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AtColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AtColors.primary,
          onPrimary: AtColors.white,
          secondary: AtColors.primaryLight,
          surface: AtColors.white,
          onSurface: AtColors.ink,
          error: AtColors.pinkFg,
          outline: AtColors.inputBorder,
          outlineVariant: AtColors.cardBorder,
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
      colorScheme: scheme,
      fontFamily: AtTextStyles.fontFamily,
      scaffoldBackgroundColor: AtColors.white,
      canvasColor: AtColors.white,
      textTheme: textTheme.apply(
        bodyColor: AtColors.ink,
        displayColor: AtColors.ink,
      ),
      dividerColor: AtColors.divider,
      splashFactory: InkRipple.splashFactory,
      focusColor: AtColors.focusRing,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AtColors.ink,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AtColors.white,
        modalBackgroundColor: AtColors.white,
        modalBarrierColor: AtColors.scrimSheet,
        shape: RoundedRectangleBorder(borderRadius: AtRadii.sheetTop),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AtColors.white,
        barrierColor: AtColors.scrimModal,
        shape: RoundedRectangleBorder(borderRadius: AtRadii.modal),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
