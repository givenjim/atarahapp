import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/pump_app.dart';

String _asset(WidgetTester t) {
  final loader = t.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader;
  return (loader as SvgAssetLoader).assetName;
}

void main() {
  group('AtLogo picks the artwork from the active appearance', () {
    testWidgets('no-brand-line: colour in light, reversed in dark', (t) async {
      await t.pumpAt(AtLogo(width: 140));
      expect(_asset(t), 'assets/brand/atarah-logo-notagline-color.svg');
      await t.pumpAt(AtLogo(width: 140), appearance: AtAppearance.dark);
      await t.pumpAndSettle();
      expect(_asset(t), 'assets/brand/atarah-logo-notagline-reversed.svg');
    });

    testWidgets('primary: colour in light, reversed in dark', (t) async {
      await t.pumpAt(AtLogo(variant: AtLogoVariant.primary, width: 300));
      expect(_asset(t), 'assets/brand/atarah-logo-primary-color.svg');
      await t.pumpAt(
        AtLogo(variant: AtLogoVariant.primary, width: 300),
        appearance: AtAppearance.dark,
      );
      await t.pumpAndSettle();
      expect(_asset(t), 'assets/brand/atarah-logo-primary-reversed.svg');
    });

    testWidgets('symbol keeps its gradients in both appearances', (t) async {
      await t.pumpAt(const AtLogo.symbol(width: 26));
      expect(_asset(t), 'assets/brand/atarah-symbol-color.svg');
      await t.pumpAt(
        const AtLogo.symbol(width: 26),
        appearance: AtAppearance.dark,
      );
      await t.pumpAndSettle();
      expect(_asset(t), 'assets/brand/atarah-symbol-color.svg');
    });

    testWidgets('explicit styles ignore the appearance', (t) async {
      await t.pumpAt(
        AtLogo(
          variant: AtLogoVariant.primary,
          width: 300,
          style: AtLogoStyle.reversed,
        ),
      );
      expect(_asset(t), 'assets/brand/atarah-logo-primary-reversed.svg');
      await t.pumpAt(
        const AtLogo.symbol(width: 20, style: AtLogoStyle.monoWhite),
      );
      expect(_asset(t), 'assets/brand/atarah-symbol-mono-white.svg');
    });

    test('every referenced asset exists in the logo pack naming', () {
      for (final v in AtLogoVariant.values) {
        for (final s in AtLogoStyle.values) {
          for (final b in Brightness.values) {
            expect(
              AtLogo.assetFor(v, s, b),
              matches(
                RegExp(
                  r'^assets/brand/atarah-(logo-(primary|notagline)|symbol)-(color|reversed|mono-white|mono-dark)\.svg$',
                ),
              ),
            );
          }
        }
      }
    });
  });

  group('AtLogo minimum sizes (debug assert, Master Prompt 8.4)', () {
    test('primary needs 300 px', () {
      expect(
        () => AtLogo(variant: AtLogoVariant.primary, width: 299),
        throwsAssertionError,
      );
      expect(AtLogo(variant: AtLogoVariant.primary, width: 300).width, 300);
    });
    test('no-brand-line needs 120 px', () {
      expect(
        () => AtLogo(variant: AtLogoVariant.noBrandLine, width: 119),
        throwsAssertionError,
      );
      expect(AtLogo(width: 120).width, 120);
    });
    test('symbol needs 20 px', () {
      // Built with a runtime value: the const constructor would be rejected at compile time.
      final w = [19.0].first;
      expect(() => AtLogo.symbol(width: w), throwsAssertionError);
      expect(const AtLogo.symbol(width: 20).width, 20);
    });
  });

  group('AtAppearanceToggle', () {
    testWidgets('light: sun icon, shows Light, tapping asks for dark', (
      t,
    ) async {
      AtAppearance? picked;
      await t.pumpAt(
        AtAppearanceToggle(
          value: AtAppearance.light,
          onChanged: (v) => picked = v,
        ),
      );
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.byIcon(LucideIcons.sun), findsOneWidget);
      await t.tap(find.text('Appearance'));
      expect(picked, AtAppearance.dark);
    });

    testWidgets('dark: moon icon, shows Dark, tapping asks for light', (
      t,
    ) async {
      AtAppearance? picked;
      await t.pumpAt(
        AtAppearanceToggle(
          value: AtAppearance.dark,
          onChanged: (v) => picked = v,
        ),
        appearance: AtAppearance.dark,
      );
      expect(find.text('Dark'), findsOneWidget);
      expect(find.byIcon(LucideIcons.moon), findsOneWidget);
      await t.tap(find.text('Appearance'));
      expect(picked, AtAppearance.light);
    });
  });

  group('Brand components', () {
    testWidgets('system-author avatar shows the symbol on a Mist circle', (
      t,
    ) async {
      await t.pumpAt(const AtAvatar.system());
      expect(find.byType(AtLogo), findsOneWidget);
      final box = t.widget<Container>(
        find
            .descendant(
              of: find.byType(AtAvatar),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((box.decoration! as BoxDecoration).color, AtColors.light.mist);
    });

    testWidgets('AtBrandRing is hidden from accessibility and pointers', (
      t,
    ) async {
      await t.pumpAt(
        const SizedBox(
          width: 200,
          height: 100,
          child: Stack(children: [AtBrandRing()]),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(AtBrandRing),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AtBrandRing),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
    });

    testWidgets('AtProPill shows the localised label and the crown', (t) async {
      await t.pumpAt(const AtProPill());
      expect(find.text('Pro'), findsOneWidget);
      expect(find.byIcon(LucideIcons.crown), findsOneWidget);
    });

    testWidgets('AtColors lerps between the two appearances', (t) async {
      final mid = AtColors.light.lerp(AtColors.dark, 0.5);
      expect(mid.background, isNot(AtColors.light.background));
      expect(mid.background, isNot(AtColors.dark.background));
      expect(AtColors.light.lerp(AtColors.dark, 1).ink, AtColors.dark.ink);
    });
  });
}
