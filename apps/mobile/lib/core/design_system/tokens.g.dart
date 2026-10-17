// GENERATED FILE. Do not edit: change packages/design-tokens/tokens.json and run `pnpm gen:tokens`.
// ignore_for_file: public_member_api_docs, constant_identifier_names
import 'package:flutter/painting.dart';

/// Colour tokens.
abstract final class AtColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF15133D);
  static const Color body = Color(0xFF4A4868);
  static const Color longForm = Color(0xFF2C2A50);
  static const Color muted = Color(0xFF6F6D85);
  static const Color faint = Color(0xFFA3A1B8);
  static const Color primary = Color(0xFF5B45F0);
  static const Color primaryPressed = Color(0xFF4330D6);
  static const Color primaryLight = Color(0xFF7B6CF6);
  static const Color violet1 = Color(0xFF8B7BFF);
  static const Color violet2 = Color(0xFFA78BFA);
  static const Color violet3 = Color(0xFFB9ADFF);
  static const Color tint1 = Color(0xFFF1EEFF);
  static const Color tint2 = Color(0xFFECE8FF);
  static const Color tint3 = Color(0xFFF6F4FF);
  static const Color tint4 = Color(0xFFF8F6FF);
  static const Color cardBorder = Color(0xFFECEBF4);
  static const Color inputBorder = Color(0xFFE4E2EF);
  static const Color inputFill = Color(0xFFFAFAFE);
  static const Color softTile = Color(0xFFF7F6FD);
  static const Color segmentedTrack = Color(0xFFF5F4FB);
  static const Color divider = Color(0xFFF0EFF6);
  static const Color divider2 = Color(0xFFF2F1F8);
  static const Color secondaryBorder = Color(0xFFDCD8F5);
  static const Color dashedBorder = Color(0xFFCFC8FB);
  static const Color toggleOff = Color(0xFFDCDBE6);
  static const Color progressTrack = Color(0xFFEFEDF7);
  static const Color focusRing = Color(0xFFEFECFF);
  static const Color disabledFill = Color(0xFFE4E2EF);
  static const Color disabledText = Color(0xFFA3A1B8);
  static const Color star = Color(0xFFF5A524);
  static const Color proText = Color(0xFF805400);
  static const Color successBg = Color(0xFFE9F8EE);
  static const Color successFg = Color(0xFF1F9D55);
  static const Color successStrong = Color(0xFF16784A);
  static const Color warningBg = Color(0xFFFFF1E5);
  static const Color warningFg = Color(0xFFF08A24);
  static const Color warningStrong = Color(0xFFA95A0E);
  static const Color pinkBg = Color(0xFFFDECF2);
  static const Color pinkFg = Color(0xFFE8457A);
  static const Color pinkStrong = Color(0xFFC62F63);
  static const Color infoBg = Color(0xFFEAF3FF);
  static const Color infoFg = Color(0xFF2F6FE0);
  static const Color infoStrong = Color(0xFF2D69D5);
  static const Color purpleBg = Color(0xFFF6F0FF);
  static const Color purpleFg = Color(0xFF8B5CF6);
  static const Color purpleStrong = Color(0xFF7C52DB);
  static const Color amberBg = Color(0xFFFFF8EC);
  static const Color amberFg = Color(0xFFC78A10);
  static const Color amberStrong = Color(0xFF97690C);
  static const Color neutralBg = Color(0xFFF2F1F6);
  static const Color neutralFg = Color(0xFF4A4868);
  static const Color neutralStrong = Color(0xFF4A4868);
  static const Color washDefault = Color(0xFFE4DCFF);
  static const Color washOpportunities = Color(0xFFFFE6D1);
  static const Color washLearning = Color(0xFFD8F5E3);
  static const Color washCommunity = Color(0xFFFDE0EA);
  static const Color washSettings = Color(0xFFECE6FF);
  static const Color scrimSheet = Color.fromRGBO(21, 19, 61, 0.45);
  static const Color scrimModal = Color.fromRGBO(21, 19, 61, 0.5);
}

/// Gradient tokens.
abstract final class AtGradients {
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF7B6CF6), Color(0xFF5A46EE)],
    stops: <double>[0.0, 1.0],
  );
  static const LinearGradient ctaSquare = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF7B6CF6), Color(0xFF5A46EE)],
    stops: <double>[0.0, 1.0],
  );
  static const LinearGradient darkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF1C1A4A), Color(0xFF25206A), Color(0xFF2F2783)],
    stops: <double>[0.0, 0.55, 1.0],
  );
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF4A36E0), Color(0xFF3B2BC4)],
    stops: <double>[0.0, 1.0],
  );
  static const LinearGradient ai = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFA78BFA), Color(0xFF5A46EE)],
    stops: <double>[0.0, 1.0],
  );
  static const LinearGradient pro = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFFDE7C4), Color(0xFFFBD38D)],
    stops: <double>[0.0, 1.0],
  );
}

/// Shadow tokens (each is a list so it can be passed straight to BoxDecoration.boxShadow).
abstract final class AtShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(40, 30, 120, 0.04),
      offset: Offset(0.0, 4.0),
      blurRadius: 16.0,
    ),
  ];
  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(60, 40, 160, 0.1),
      offset: Offset(0.0, 6.0),
      blurRadius: 18.0,
    ),
  ];
  static const List<BoxShadow> cta = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(91, 69, 240, 0.28),
      offset: Offset(0.0, 10.0),
      blurRadius: 22.0,
    ),
  ];
  static const List<BoxShadow> selectedTile = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(91, 69, 240, 0.3),
      offset: Offset(0.0, 8.0),
      blurRadius: 18.0,
    ),
  ];
  static const List<BoxShadow> darkCard = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(28, 26, 74, 0.25),
      offset: Offset(0.0, 14.0),
      blurRadius: 30.0,
    ),
  ];
  static const List<BoxShadow> sheet = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(21, 19, 61, 0.2),
      offset: Offset(0.0, -10.0),
      blurRadius: 40.0,
    ),
  ];
  static const List<BoxShadow> modal = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(21, 19, 61, 0.3),
      offset: Offset(0.0, 30.0),
      blurRadius: 60.0,
    ),
  ];
}

/// Corner radius tokens.
abstract final class AtRadii {
  static const double pillValue = 999.0;
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999.0));
  static const double cardValue = 16.0;
  static const BorderRadius card = BorderRadius.all(Radius.circular(16.0));
  static const double cardLgValue = 18.0;
  static const BorderRadius cardLg = BorderRadius.all(Radius.circular(18.0));
  static const double panelValue = 20.0;
  static const BorderRadius panel = BorderRadius.all(Radius.circular(20.0));
  static const double panelLgValue = 22.0;
  static const BorderRadius panelLg = BorderRadius.all(Radius.circular(22.0));
  static const double passportValue = 24.0;
  static const BorderRadius passport = BorderRadius.all(Radius.circular(24.0));
  static const double inputValue = 14.0;
  static const BorderRadius input = BorderRadius.all(Radius.circular(14.0));
  static const double backButtonValue = 14.0;
  static const BorderRadius backButton = BorderRadius.all(
    Radius.circular(14.0),
  );
  static const double tileValue = 12.0;
  static const BorderRadius tile = BorderRadius.all(Radius.circular(12.0));
  static const double tileLgValue = 14.0;
  static const BorderRadius tileLg = BorderRadius.all(Radius.circular(14.0));
  static const double sheetValue = 28.0;
  static const BorderRadius sheet = BorderRadius.all(Radius.circular(28.0));
  static const double modalValue = 26.0;
  static const BorderRadius modal = BorderRadius.all(Radius.circular(26.0));
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(28.0),
    topRight: Radius.circular(28.0),
  );
}

/// Spacing and size tokens.
abstract final class AtSpacing {
  static const double gutter = 22.0;
  static const double topBarV = 6.0;
  static const double topBarH = 14.0;
  static const double sectionGap = 24.0;
  static const double sectionGapLg = 28.0;
  static const double cardPadding = 16.0;
  static const double listGap = 10.0;
  static const double listGapLg = 12.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

abstract final class AtSizes {
  static const double touchTarget = 48.0;
  static const double buttonLg = 54.0;
  static const double buttonMd = 48.0;
  static const double buttonSm = 34.0;
  static const double input = 52.0;
  static const double backButton = 44.0;
  static const double toggleWidth = 48.0;
  static const double toggleHeight = 28.0;
  static const double tabBar = 72.0;
}

/// Motion durations.
abstract final class AtMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
}

/// Text styles. Plus Jakarta Sans is bundled as an asset (never fetched at runtime).
abstract final class AtTextStyles {
  static const String fontFamily = 'Plus Jakarta Sans';
  static const TextStyle tabTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.64,
  );
  static const TextStyle subTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.56,
  );
  static const TextStyle detailTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.24,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const TextStyle sectionTitleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.5,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );
  static const TextStyle meta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle metaSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const TextStyle chipSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.32,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle buttonSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.22,
  );
  static const TextStyle tagline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.54,
  );
}
