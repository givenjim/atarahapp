import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in the real Atarah theme and localisations.
Widget atApp(
  Widget child, {
  double textScale = 1.0,
  bool scaffold = true,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AtTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
      ),
      child: scaffold
          ? Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  child: child,
                ),
              ),
            )
          : child,
    ),
  );
}

extension PumpAtApp on WidgetTester {
  Future<void> pumpAt(
    Widget child, {
    double textScale = 1.0,
    bool scaffold = true,
    Size size = const Size(390, 844),
  }) async {
    view.physicalSize = size * 1.0;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    await pumpWidget(atApp(child, textScale: textScale, scaffold: scaffold));
    // One frame; animated widgets (skeleton) never settle.
    await pump();
  }
}

/// Visible size of the first widget of type [T] (the painted box, not the tap target).
Size sizeOf<T extends Widget>(WidgetTester tester) =>
    tester.getSize(find.byType(T).first);
