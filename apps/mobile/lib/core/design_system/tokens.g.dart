// GENERATED FILE. Do not edit: change packages/design-tokens/tokens.json and run `pnpm gen:tokens`.
// ignore_for_file: public_member_api_docs, constant_identifier_names
import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/painting.dart';

/// The six brand colours (Master Prompt 8.1). Identical in both appearances.
abstract final class AtBrand {
  static const Color midnight = Color(0xFF17153F);
  static const Color indigo = Color(0xFF5145D8);
  static const Color violet = Color(0xFF7968FF);
  static const Color coral = Color(0xFFF04478);
  static const Color tangerine = Color(0xFFFF8A32);
  static const Color mist = Color(0xFFF6F5FC);
}

/// Every colour role, gradient and shadow that depends on the appearance, as a [ThemeExtension].
/// Read it with `context.at` (theme.dart). [light] and [dark] are the two const sets.
class AtColors extends ThemeExtension<AtColors> {
  const AtColors({
    required this.background,
    required this.surface,
    required this.raised,
    required this.mist,
    required this.white,
    required this.ink,
    required this.longForm,
    required this.body,
    required this.muted,
    required this.faint,
    required this.primary,
    required this.primaryPressed,
    required this.primaryFill,
    required this.primaryLight,
    required this.violetTint1,
    required this.violetTint2,
    required this.primaryTint,
    required this.primaryTintStrong,
    required this.primaryTintFaint,
    required this.violetSurface,
    required this.indigoSurface,
    required this.coral,
    required this.coralSurface,
    required this.coralStrong,
    required this.tangerine,
    required this.tangerineSurface,
    required this.tangerineStrong,
    required this.amberSurface,
    required this.amberStrong,
    required this.successSurface,
    required this.successStrong,
    required this.successIcon,
    required this.neutralSurface,
    required this.neutralText,
    required this.cardBorder,
    required this.inputBorder,
    required this.divider,
    required this.divider2,
    required this.toggleOff,
    required this.radioRing,
    required this.inputFill,
    required this.softTile,
    required this.segmentedTrack,
    required this.progressTrack,
    required this.secondaryBorder,
    required this.dashedBorder,
    required this.focusRing,
    required this.disabledFill,
    required this.disabledText,
    required this.star,
    required this.skeleton,
    required this.skeletonShimmer,
    required this.washDefault,
    required this.washOpportunities,
    required this.washLearning,
    required this.washCommunity,
    required this.washSettings,
    required this.scrimSheet,
    required this.scrimModal,
    required this.darkCardGradient,
    required this.shadowCard,
    required this.shadowFloating,
    required this.shadowCta,
    required this.shadowSelectedTile,
    required this.shadowDarkCard,
    required this.shadowSheet,
    required this.shadowModal,
  });

  final Color background;
  final Color surface;
  final Color raised;
  final Color mist;
  final Color white;
  final Color ink;
  final Color longForm;
  final Color body;
  final Color muted;
  final Color faint;
  final Color primary;
  final Color primaryPressed;
  final Color primaryFill;
  final Color primaryLight;
  final Color violetTint1;
  final Color violetTint2;
  final Color primaryTint;
  final Color primaryTintStrong;
  final Color primaryTintFaint;
  final Color violetSurface;
  final Color indigoSurface;
  final Color coral;
  final Color coralSurface;
  final Color coralStrong;
  final Color tangerine;
  final Color tangerineSurface;
  final Color tangerineStrong;
  final Color amberSurface;
  final Color amberStrong;
  final Color successSurface;
  final Color successStrong;
  final Color successIcon;
  final Color neutralSurface;
  final Color neutralText;
  final Color cardBorder;
  final Color inputBorder;
  final Color divider;
  final Color divider2;
  final Color toggleOff;
  final Color radioRing;
  final Color inputFill;
  final Color softTile;
  final Color segmentedTrack;
  final Color progressTrack;
  final Color secondaryBorder;
  final Color dashedBorder;
  final Color focusRing;
  final Color disabledFill;
  final Color disabledText;
  final Color star;
  final Color skeleton;
  final Color skeletonShimmer;
  final Color washDefault;
  final Color washOpportunities;
  final Color washLearning;
  final Color washCommunity;
  final Color washSettings;
  final Color scrimSheet;
  final Color scrimModal;
  final LinearGradient darkCardGradient;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowFloating;
  final List<BoxShadow> shadowCta;
  final List<BoxShadow> shadowSelectedTile;
  final List<BoxShadow> shadowDarkCard;
  final List<BoxShadow> shadowSheet;
  final List<BoxShadow> shadowModal;

  static const AtColors light = AtColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    mist: Color(0xFFF6F5FC),
    white: Color(0xFFFFFFFF),
    ink: Color(0xFF17153F),
    longForm: Color(0xFF2C2A50),
    body: Color(0xFF4A4868),
    muted: Color(0xFF77758F),
    faint: Color(0xFFA3A1B8),
    primary: Color(0xFF5145D8),
    primaryPressed: Color(0xFF3F34B8),
    primaryFill: Color(0xFF5145D8),
    primaryLight: Color(0xFF7968FF),
    violetTint1: Color(0xFF9A8DFF),
    violetTint2: Color(0xFFB8AFFF),
    primaryTint: Color(0xFFEFEDFF),
    primaryTintStrong: Color(0xFFE7E4FF),
    primaryTintFaint: Color(0xFFF8F7FF),
    violetSurface: Color(0xFFF2F0FF),
    indigoSurface: Color(0xFFEEEDFB),
    coral: Color(0xFFF04478),
    coralSurface: Color(0xFFFDE8EF),
    coralStrong: Color(0xFFC4245A),
    tangerine: Color(0xFFFF8A32),
    tangerineSurface: Color(0xFFFFF1E5),
    tangerineStrong: Color(0xFFB5530C),
    amberSurface: Color(0xFFFFF6EC),
    amberStrong: Color(0xFFB5530C),
    successSurface: Color(0xFFE9F8EE),
    successStrong: Color(0xFF16784A),
    successIcon: Color(0xFF1F9D55),
    neutralSurface: Color(0xFFF2F1F6),
    neutralText: Color(0xFF4A4868),
    cardBorder: Color(0xFFECEBF4),
    inputBorder: Color(0xFFE4E2EF),
    divider: Color(0xFFF0EFF6),
    divider2: Color(0xFFF2F1F8),
    toggleOff: Color(0xFFDCDBE6),
    radioRing: Color(0xFFCFCCDF),
    inputFill: Color(0xFFF6F5FC),
    softTile: Color(0xFFF6F5FC),
    segmentedTrack: Color(0xFFF6F5FC),
    progressTrack: Color(0xFFEFEDFF),
    secondaryBorder: Color(0xFFE7E4FF),
    dashedBorder: Color(0xFFB8AFFF),
    focusRing: Color(0xFFEFEDFF),
    disabledFill: Color(0xFFE4E2EF),
    disabledText: Color(0xFFA3A1B8),
    star: Color(0xFFFF8A32),
    skeleton: Color(0xFFF6F5FC),
    skeletonShimmer: Color(0xFFEFEDFF),
    washDefault: Color(0xFFE7E4FF),
    washOpportunities: Color(0xFFFFE8D6),
    washLearning: Color(0xFFE7E4FF),
    washCommunity: Color(0xFFFDE3EC),
    washSettings: Color(0xFFEFEDFF),
    scrimSheet: Color.fromRGBO(23, 21, 63, 0.45),
    scrimModal: Color.fromRGBO(23, 21, 63, 0.5),
    darkCardGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF17153F), Color(0xFF1F1C55), Color(0xFF2A2478)], stops: <double>[0.0, 0.5, 1.0]),
    shadowCard: <BoxShadow>[BoxShadow(color: Color.fromRGBO(40, 30, 120, 0.04), offset: Offset(0.0, 4.0), blurRadius: 16.0)],
    shadowFloating: <BoxShadow>[BoxShadow(color: Color.fromRGBO(60, 40, 160, 0.1), offset: Offset(0.0, 6.0), blurRadius: 18.0)],
    shadowCta: <BoxShadow>[BoxShadow(color: Color.fromRGBO(81, 69, 216, 0.28), offset: Offset(0.0, 10.0), blurRadius: 22.0)],
    shadowSelectedTile: <BoxShadow>[BoxShadow(color: Color.fromRGBO(81, 69, 216, 0.3), offset: Offset(0.0, 8.0), blurRadius: 18.0)],
    shadowDarkCard: <BoxShadow>[BoxShadow(color: Color.fromRGBO(23, 21, 63, 0.25), offset: Offset(0.0, 14.0), blurRadius: 30.0)],
    shadowSheet: <BoxShadow>[BoxShadow(color: Color.fromRGBO(23, 21, 63, 0.2), offset: Offset(0.0, -10.0), blurRadius: 40.0)],
    shadowModal: <BoxShadow>[BoxShadow(color: Color.fromRGBO(23, 21, 63, 0.3), offset: Offset(0.0, 30.0), blurRadius: 60.0)],
  );

  static const AtColors dark = AtColors(
    background: Color(0xFF0F0D2B),
    surface: Color(0xFF17153F),
    raised: Color(0xFF1F1C55),
    mist: Color(0xFF1C1A4A),
    white: Color(0xFFFFFFFF),
    ink: Color(0xFFF6F5FC),
    longForm: Color(0xFFDCD9F2),
    body: Color(0xFFB9B6D6),
    muted: Color(0xFF9592B8),
    faint: Color(0xFF75729A),
    primary: Color(0xFF9A8DFF),
    primaryPressed: Color(0xFFB8AFFF),
    primaryFill: Color(0xFF5145D8),
    primaryLight: Color(0xFF9A8DFF),
    violetTint1: Color(0xFF9A8DFF),
    violetTint2: Color(0xFFB8AFFF),
    primaryTint: Color(0xFF25215E),
    primaryTintStrong: Color(0xFF2C2870),
    primaryTintFaint: Color(0xFF1C1A4A),
    violetSurface: Color(0xFF231F5A),
    indigoSurface: Color(0xFF221F55),
    coral: Color(0xFFF04478),
    coralSurface: Color(0xFF3A1838),
    coralStrong: Color(0xFFF04478),
    tangerine: Color(0xFFFF8A32),
    tangerineSurface: Color(0xFF3A2420),
    tangerineStrong: Color(0xFFFF8A32),
    amberSurface: Color(0xFF33221F),
    amberStrong: Color(0xFFFF8A32),
    successSurface: Color(0xFF0F3A2A),
    successStrong: Color(0xFF5FD39A),
    successIcon: Color(0xFF3CC17A),
    neutralSurface: Color(0xFF24223F),
    neutralText: Color(0xFFB9B6D6),
    cardBorder: Color(0xFF2A2766),
    inputBorder: Color(0xFF322F6E),
    divider: Color(0xFF221F4D),
    divider2: Color(0xFF221F4D),
    toggleOff: Color(0xFF34325A),
    radioRing: Color(0xFF4A4870),
    inputFill: Color(0xFF1C1A4A),
    softTile: Color(0xFF1C1A4A),
    segmentedTrack: Color(0xFF1C1A4A),
    progressTrack: Color(0xFF25215E),
    secondaryBorder: Color(0xFF2C2870),
    dashedBorder: Color(0xFF4A4870),
    focusRing: Color(0xFF25215E),
    disabledFill: Color(0xFF322F6E),
    disabledText: Color(0xFF75729A),
    star: Color(0xFFFF8A32),
    skeleton: Color(0xFF1C1A4A),
    skeletonShimmer: Color(0xFF25225E),
    washDefault: Color(0xFF2C2870),
    washOpportunities: Color(0xFF2E1E22),
    washLearning: Color(0xFF2C2870),
    washCommunity: Color(0xFF2E1533),
    washSettings: Color(0xFF25215E),
    scrimSheet: Color.fromRGBO(23, 21, 63, 0.45),
    scrimModal: Color.fromRGBO(23, 21, 63, 0.5),
    darkCardGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF1F1C55), Color(0xFF2A2478), Color(0xFF3828C3)], stops: <double>[0.0, 0.5, 1.0]),
    shadowCard: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowFloating: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowCta: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowSelectedTile: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowDarkCard: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowSheet: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
    shadowModal: <BoxShadow>[BoxShadow(color: Color(0xFF2A2766), spreadRadius: 1.0)],
  );

  @override
  AtColors copyWith({
    Color? background,
    Color? surface,
    Color? raised,
    Color? mist,
    Color? white,
    Color? ink,
    Color? longForm,
    Color? body,
    Color? muted,
    Color? faint,
    Color? primary,
    Color? primaryPressed,
    Color? primaryFill,
    Color? primaryLight,
    Color? violetTint1,
    Color? violetTint2,
    Color? primaryTint,
    Color? primaryTintStrong,
    Color? primaryTintFaint,
    Color? violetSurface,
    Color? indigoSurface,
    Color? coral,
    Color? coralSurface,
    Color? coralStrong,
    Color? tangerine,
    Color? tangerineSurface,
    Color? tangerineStrong,
    Color? amberSurface,
    Color? amberStrong,
    Color? successSurface,
    Color? successStrong,
    Color? successIcon,
    Color? neutralSurface,
    Color? neutralText,
    Color? cardBorder,
    Color? inputBorder,
    Color? divider,
    Color? divider2,
    Color? toggleOff,
    Color? radioRing,
    Color? inputFill,
    Color? softTile,
    Color? segmentedTrack,
    Color? progressTrack,
    Color? secondaryBorder,
    Color? dashedBorder,
    Color? focusRing,
    Color? disabledFill,
    Color? disabledText,
    Color? star,
    Color? skeleton,
    Color? skeletonShimmer,
    Color? washDefault,
    Color? washOpportunities,
    Color? washLearning,
    Color? washCommunity,
    Color? washSettings,
    Color? scrimSheet,
    Color? scrimModal,
    LinearGradient? darkCardGradient,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowFloating,
    List<BoxShadow>? shadowCta,
    List<BoxShadow>? shadowSelectedTile,
    List<BoxShadow>? shadowDarkCard,
    List<BoxShadow>? shadowSheet,
    List<BoxShadow>? shadowModal,
  }) {
    return AtColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      mist: mist ?? this.mist,
      white: white ?? this.white,
      ink: ink ?? this.ink,
      longForm: longForm ?? this.longForm,
      body: body ?? this.body,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primaryFill: primaryFill ?? this.primaryFill,
      primaryLight: primaryLight ?? this.primaryLight,
      violetTint1: violetTint1 ?? this.violetTint1,
      violetTint2: violetTint2 ?? this.violetTint2,
      primaryTint: primaryTint ?? this.primaryTint,
      primaryTintStrong: primaryTintStrong ?? this.primaryTintStrong,
      primaryTintFaint: primaryTintFaint ?? this.primaryTintFaint,
      violetSurface: violetSurface ?? this.violetSurface,
      indigoSurface: indigoSurface ?? this.indigoSurface,
      coral: coral ?? this.coral,
      coralSurface: coralSurface ?? this.coralSurface,
      coralStrong: coralStrong ?? this.coralStrong,
      tangerine: tangerine ?? this.tangerine,
      tangerineSurface: tangerineSurface ?? this.tangerineSurface,
      tangerineStrong: tangerineStrong ?? this.tangerineStrong,
      amberSurface: amberSurface ?? this.amberSurface,
      amberStrong: amberStrong ?? this.amberStrong,
      successSurface: successSurface ?? this.successSurface,
      successStrong: successStrong ?? this.successStrong,
      successIcon: successIcon ?? this.successIcon,
      neutralSurface: neutralSurface ?? this.neutralSurface,
      neutralText: neutralText ?? this.neutralText,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBorder: inputBorder ?? this.inputBorder,
      divider: divider ?? this.divider,
      divider2: divider2 ?? this.divider2,
      toggleOff: toggleOff ?? this.toggleOff,
      radioRing: radioRing ?? this.radioRing,
      inputFill: inputFill ?? this.inputFill,
      softTile: softTile ?? this.softTile,
      segmentedTrack: segmentedTrack ?? this.segmentedTrack,
      progressTrack: progressTrack ?? this.progressTrack,
      secondaryBorder: secondaryBorder ?? this.secondaryBorder,
      dashedBorder: dashedBorder ?? this.dashedBorder,
      focusRing: focusRing ?? this.focusRing,
      disabledFill: disabledFill ?? this.disabledFill,
      disabledText: disabledText ?? this.disabledText,
      star: star ?? this.star,
      skeleton: skeleton ?? this.skeleton,
      skeletonShimmer: skeletonShimmer ?? this.skeletonShimmer,
      washDefault: washDefault ?? this.washDefault,
      washOpportunities: washOpportunities ?? this.washOpportunities,
      washLearning: washLearning ?? this.washLearning,
      washCommunity: washCommunity ?? this.washCommunity,
      washSettings: washSettings ?? this.washSettings,
      scrimSheet: scrimSheet ?? this.scrimSheet,
      scrimModal: scrimModal ?? this.scrimModal,
      darkCardGradient: darkCardGradient ?? this.darkCardGradient,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowFloating: shadowFloating ?? this.shadowFloating,
      shadowCta: shadowCta ?? this.shadowCta,
      shadowSelectedTile: shadowSelectedTile ?? this.shadowSelectedTile,
      shadowDarkCard: shadowDarkCard ?? this.shadowDarkCard,
      shadowSheet: shadowSheet ?? this.shadowSheet,
      shadowModal: shadowModal ?? this.shadowModal,
    );
  }

  @override
  AtColors lerp(covariant ThemeExtension<AtColors>? other, double t) {
    if (other is! AtColors) return this;
    return AtColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      mist: Color.lerp(mist, other.mist, t)!,
      white: Color.lerp(white, other.white, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      longForm: Color.lerp(longForm, other.longForm, t)!,
      body: Color.lerp(body, other.body, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primaryFill: Color.lerp(primaryFill, other.primaryFill, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      violetTint1: Color.lerp(violetTint1, other.violetTint1, t)!,
      violetTint2: Color.lerp(violetTint2, other.violetTint2, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      primaryTintStrong: Color.lerp(primaryTintStrong, other.primaryTintStrong, t)!,
      primaryTintFaint: Color.lerp(primaryTintFaint, other.primaryTintFaint, t)!,
      violetSurface: Color.lerp(violetSurface, other.violetSurface, t)!,
      indigoSurface: Color.lerp(indigoSurface, other.indigoSurface, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralSurface: Color.lerp(coralSurface, other.coralSurface, t)!,
      coralStrong: Color.lerp(coralStrong, other.coralStrong, t)!,
      tangerine: Color.lerp(tangerine, other.tangerine, t)!,
      tangerineSurface: Color.lerp(tangerineSurface, other.tangerineSurface, t)!,
      tangerineStrong: Color.lerp(tangerineStrong, other.tangerineStrong, t)!,
      amberSurface: Color.lerp(amberSurface, other.amberSurface, t)!,
      amberStrong: Color.lerp(amberStrong, other.amberStrong, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      successIcon: Color.lerp(successIcon, other.successIcon, t)!,
      neutralSurface: Color.lerp(neutralSurface, other.neutralSurface, t)!,
      neutralText: Color.lerp(neutralText, other.neutralText, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      divider2: Color.lerp(divider2, other.divider2, t)!,
      toggleOff: Color.lerp(toggleOff, other.toggleOff, t)!,
      radioRing: Color.lerp(radioRing, other.radioRing, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      softTile: Color.lerp(softTile, other.softTile, t)!,
      segmentedTrack: Color.lerp(segmentedTrack, other.segmentedTrack, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      secondaryBorder: Color.lerp(secondaryBorder, other.secondaryBorder, t)!,
      dashedBorder: Color.lerp(dashedBorder, other.dashedBorder, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      disabledFill: Color.lerp(disabledFill, other.disabledFill, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      star: Color.lerp(star, other.star, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      skeletonShimmer: Color.lerp(skeletonShimmer, other.skeletonShimmer, t)!,
      washDefault: Color.lerp(washDefault, other.washDefault, t)!,
      washOpportunities: Color.lerp(washOpportunities, other.washOpportunities, t)!,
      washLearning: Color.lerp(washLearning, other.washLearning, t)!,
      washCommunity: Color.lerp(washCommunity, other.washCommunity, t)!,
      washSettings: Color.lerp(washSettings, other.washSettings, t)!,
      scrimSheet: Color.lerp(scrimSheet, other.scrimSheet, t)!,
      scrimModal: Color.lerp(scrimModal, other.scrimModal, t)!,
      darkCardGradient: LinearGradient.lerp(darkCardGradient, other.darkCardGradient, t)!,
      shadowCard: BoxShadow.lerpList(shadowCard, other.shadowCard, t)!,
      shadowFloating: BoxShadow.lerpList(shadowFloating, other.shadowFloating, t)!,
      shadowCta: BoxShadow.lerpList(shadowCta, other.shadowCta, t)!,
      shadowSelectedTile: BoxShadow.lerpList(shadowSelectedTile, other.shadowSelectedTile, t)!,
      shadowDarkCard: BoxShadow.lerpList(shadowDarkCard, other.shadowDarkCard, t)!,
      shadowSheet: BoxShadow.lerpList(shadowSheet, other.shadowSheet, t)!,
      shadowModal: BoxShadow.lerpList(shadowModal, other.shadowModal, t)!,
    );
  }
}

/// Gradients that look the same in both appearances.
abstract final class AtGradients {
  static const LinearGradient cta = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: <Color>[Color(0xFF7968FF), Color(0xFF5145D8)], stops: <double>[0.0, 1.0]);
  static const LinearGradient ctaSquare = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF7968FF), Color(0xFF5145D8)], stops: <double>[0.0, 1.0]);
  static const LinearGradient splash = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF17153F), Color(0xFF0F0D2B)], stops: <double>[0.0, 1.0]);
  static const LinearGradient ai = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF7968FF), Color(0xFF5145D8)], stops: <double>[0.0, 1.0]);
  static const LinearGradient pro = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: <Color>[Color(0xFFF04478), Color(0xFFFF8A32)], stops: <double>[0.0, 1.0]);
  static const LinearGradient brandRing = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFFF04478), Color(0xFFFF8A32)], stops: <double>[0.0, 1.0]);
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
  static const BorderRadius backButton = BorderRadius.all(Radius.circular(14.0));
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
    fontFamily: fontFamily, fontSize: 32.0, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.64,
  );
  static const TextStyle subTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 28.0, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.56,
  );
  static const TextStyle detailTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24.0, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.24,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 20.0, fontWeight: FontWeight.w700, height: 1.25,
  );
  static const TextStyle sectionTitleSm = TextStyle(
    fontFamily: fontFamily, fontSize: 17.0, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 15.0, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 14.5, fontWeight: FontWeight.w400, height: 1.6,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily, fontSize: 15.5, fontWeight: FontWeight.w400, height: 1.65,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily, fontSize: 14.0, fontWeight: FontWeight.w400, height: 1.55,
  );
  static const TextStyle meta = TextStyle(
    fontFamily: fontFamily, fontSize: 12.5, fontWeight: FontWeight.w400, height: 1.4,
  );
  static const TextStyle metaSm = TextStyle(
    fontFamily: fontFamily, fontSize: 12.0, fontWeight: FontWeight.w500, height: 1.4,
  );
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.2,
  );
  static const TextStyle chipSm = TextStyle(
    fontFamily: fontFamily, fontSize: 11.0, fontWeight: FontWeight.w600, height: 1.2,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily, fontSize: 11.0, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 1.32,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily, fontSize: 15.0, fontWeight: FontWeight.w700, height: 1.2,
  );
  static const TextStyle buttonSm = TextStyle(
    fontFamily: fontFamily, fontSize: 13.0, fontWeight: FontWeight.w700, height: 1.2,
  );
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily, fontSize: 22.0, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.22,
  );
  static const TextStyle tagline = TextStyle(
    fontFamily: fontFamily, fontSize: 11.0, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 1.54,
  );
}
