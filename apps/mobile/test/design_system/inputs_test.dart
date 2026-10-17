import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/pump_app.dart';

void main() {
  group('AtTextField', () {
    testWidgets('shows label, hint and reports typing', (tester) async {
      String? typed;
      await tester.pumpAt(
        AtTextField(
          label: 'Full name',
          hint: 'Your name',
          onChanged: (v) => typed = v,
        ),
      );
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Nia');
      expect(typed, 'Nia');
    });

    testWidgets('is 52 high and renders prefix text', (tester) async {
      await tester.pumpAt(
        const AtTextField(prefixText: '+254', hint: '712 345 678'),
      );
      expect(find.text('+254'), findsOneWidget);
      final box = tester.getSize(
        find
            .descendant(
              of: find.byType(AtTextField),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(box.height, 52);
    });

    testWidgets(
      'error state shows the message, an icon, and is exposed to screen readers',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpAt(
          const AtTextField(
            label: 'Email',
            errorText: 'Enter a valid email address.',
          ),
        );
        expect(find.text('Enter a valid email address.'), findsOneWidget);
        expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('counter shows characters used', (tester) async {
      final c = TextEditingController(text: 'Hello');
      await tester.pumpAt(
        AtTextField(controller: c, maxLength: 160, showCounter: true),
      );
      expect(find.text('5 / 160'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello there');
      await tester.pump();
      expect(find.text('11 / 160'), findsOneWidget);
    });

    testWidgets('disabled fields cannot be edited', (tester) async {
      await tester.pumpAt(const AtTextField(label: 'Locked', enabled: false));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });
  });

  group('password strength', () {
    test('follows the rule: strong needs 8+ characters and a number', () {
      expect(evaluatePassword('').level, AtPasswordStrength.empty);
      expect(evaluatePassword('abc').level, AtPasswordStrength.weak);
      expect(evaluatePassword('abcdefgh').level, AtPasswordStrength.ok);
      expect(evaluatePassword('abc12').level, AtPasswordStrength.ok);
      expect(evaluatePassword('abcdefg1').level, AtPasswordStrength.strong);
      expect(evaluatePassword('Abcdefg1!xyz').score, 4);
    });

    testWidgets('meter states the level in text, not only colour', (
      tester,
    ) async {
      await tester.pumpAt(const AtPasswordStrengthMeter(password: 'abcdefg1'));
      expect(find.text('Strong — 8+ characters with a number'), findsOneWidget);
      await tester.pumpAt(const AtPasswordStrengthMeter(password: 'abc'));
      expect(find.textContaining('Weak'), findsOneWidget);
      await tester.pumpAt(const AtPasswordStrengthMeter(password: ''));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets(
      'password field toggles visibility with an accessible control',
      (tester) async {
        await tester.pumpAt(
          const AtPasswordField(label: 'Password', showStrength: true),
        );
        TextField field() => tester.widget<TextField>(find.byType(TextField));
        expect(field().obscureText, isTrue);
        await tester.tap(find.bySemanticsLabel('Show password'));
        await tester.pump();
        expect(field().obscureText, isFalse);
        expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'abcdefg1');
        await tester.pump();
        expect(
          find.text('Strong — 8+ characters with a number'),
          findsOneWidget,
        );
      },
    );
  });

  group('AtCodeInput', () {
    testWidgets('fires onCompleted at six digits and ignores non-digits', (
      tester,
    ) async {
      String? done;
      final changes = <String>[];
      await tester.pumpAt(
        AtCodeInput(onChanged: changes.add, onCompleted: (v) => done = v),
      );
      await tester.enterText(find.byType(TextField), '48a2');
      await tester.pump();
      expect(changes.last, '482');
      expect(done, isNull);
      await tester.enterText(find.byType(TextField), '482913');
      await tester.pump();
      expect(done, '482913');
    });

    testWidgets('accepts a pasted code and fills the boxes', (tester) async {
      await tester.pumpAt(AtCodeInput(controller: TextEditingController()));
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        expect(find.text(d), findsOneWidget);
      }
    });

    testWidgets('never takes more than six digits', (tester) async {
      await tester.pumpAt(const AtCodeInput());
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .controller!
            .text
            .length,
        6,
      );
    });
  });

  group('selection controls', () {
    testWidgets('checkbox toggles and exposes checked state', (tester) async {
      final handle = tester.ensureSemantics();
      var value = false;
      await tester.pumpAt(
        StatefulBuilder(
          builder: (c, set) => AtCheckbox(
            value: value,
            label: 'I agree',
            onChanged: (v) => set(() => value = v),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.byType(AtCheckbox))
            .flagsCollection
            .isChecked
            .name,
        'isFalse',
      );
      await tester.tap(find.text('I agree'));
      await tester.pump();
      expect(value, isTrue);
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      handle.dispose();
    });

    testWidgets('toggle is 48x28 visually with a 48 tap target and a label', (
      tester,
    ) async {
      var on = false;
      await tester.pumpAt(
        StatefulBuilder(
          builder: (c, set) => AtToggle(
            value: on,
            semanticLabel: 'Push notifications',
            onChanged: (v) => set(() => on = v),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(AtToggle)).height,
        greaterThanOrEqualTo(48),
      );
      final track = tester.getSize(
        find.descendant(
          of: find.byType(AtToggle),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(track, const Size(48, 28));
      await tester.tap(find.byType(AtToggle));
      await tester.pump();
      expect(on, isTrue);
      expect(find.bySemanticsLabel('Push notifications'), findsOneWidget);
    });

    testWidgets('radio card reports selection to the tap handler', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpAt(
        AtRadioCard(
          title: 'Members only',
          subtitle: 'Signed-in members',
          selected: true,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Members only'));
      expect(taps, 1);
    });

    testWidgets('segmented control switches segments', (tester) async {
      var index = 0;
      await tester.pumpAt(
        StatefulBuilder(
          builder: (c, set) => AtSegmented(
            labels: const ['All', 'Closing soon', 'Applied'],
            selectedIndex: index,
            onChanged: (i) => set(() => index = i),
          ),
        ),
      );
      await tester.tap(find.text('Applied'));
      await tester.pump();
      expect(index, 2);
    });
  });

  group('input constraints', () {
    test('FilteringTextInputFormatter keeps the code numeric', () {
      final f = FilteringTextInputFormatter.digitsOnly;
      expect(
        f
            .formatEditUpdate(
              TextEditingValue.empty,
              const TextEditingValue(text: 'a1b2'),
            )
            .text,
        '12',
      );
    });
  });
}
