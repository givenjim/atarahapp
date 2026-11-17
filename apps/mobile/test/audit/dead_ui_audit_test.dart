import 'dart:io';

import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/features/shell/future_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../accessibility/phase1_screens_test.dart'
    show openScreen, phase1Screens, Phase1Screen;
import '../support/pump_app.dart';

/// P1-M12 dead-UI audit (Master Prompt P1-M12 item 5; CLAUDE.md "No dead UI", "No hard-coded sample data"):
///  1. every route constant in `core/routing/routes.dart` is registered in the router,
///  2. every labelled future screen reads "Soon · P#" or "Soon · Later",
///  3. every visible entry point (each tappable on the hub screens) opens a real screen, a sheet or dialog, or a
///     labelled future screen, never a missing route,
///  4. no sample data (the demo people, the demo seed's titles) is written into UI code.
Directory get _lib => Directory('lib');

List<File> _dartFiles(Directory d) => [
  for (final f in d.listSync(recursive: true))
    if (f is File &&
        f.path.endsWith('.dart') &&
        !f.path.contains('generated') &&
        !f.path.endsWith('.g.dart') &&
        !f.path.contains('l10n${Platform.pathSeparator}app_localizations'))
      f,
];

/// Route patterns that are registered in code (a path from `Routes.*`).
Set<String> _registeredConstants() {
  final router = File('lib/core/routing/app_router.dart').readAsStringSync();
  return {
    for (final m in RegExp(r'Routes\.(\w+)').allMatches(router)) m.group(1)!,
  };
}

void main() {
  group('route constants', () {
    final routes = File('lib/core/routing/routes.dart').readAsStringSync();
    // `static const name = '/path';` (the helper functions and sets are not routes).
    final constants = {
      for (final m in RegExp(
        r"static const (\w+) = '(/[^']*)';",
      ).allMatches(routes))
        m.group(1)!: m.group(2)!,
    };

    test('there are route constants to check', () {
      expect(constants.length, greaterThan(40));
    });

    test('every constant is registered with the router', () {
      final registered = _registeredConstants();
      final missing = [
        for (final name in constants.keys)
          if (!registered.contains(name)) name,
      ];
      expect(missing, isEmpty, reason: 'unregistered routes: $missing');
    });

    test('every registered `Routes.x` exists', () {
      final registered = _registeredConstants();
      final unknown = [
        for (final name in registered)
          if (!constants.containsKey(name) &&
              !RegExp(
                'static (String|const|bool|final)? ?\\w* $name\\b|'
                '$name\\(',
              ).hasMatch(routes))
            name,
      ];
      expect(unknown, isEmpty);
    });

    // Every Phase 1 path (with an example id) opens a real screen, not go_router's "page not found".
    for (final Phase1Screen s in phase1Screens) {
      testWidgets('${s.path} opens a screen', (t) async {
        await openScreen(t, s);
        expect(find.textContaining('no routes for location'), findsNothing);
        expect(find.text('Page Not Found'), findsNothing);
        expect(t.takeException(), isNull);
      });
    }
  });

  group('labelled future screens', () {
    for (final (phase, label) in [
      ('p1', 'Soon · P1'),
      ('p2', 'Soon · P2'),
      ('p3', 'Soon · P3'),
      ('later', 'Soon · Later'),
    ]) {
      testWidgets('$phase reads "$label"', (t) async {
        await t.pumpAt(
          FutureRouteScreen(phase: phase, name: 'Marketplace'),
          scaffold: false,
        );
        expect(find.text(label), findsOneWidget);
        expect(find.byType(AtFutureScreen), findsOneWidget);
      });
    }

    test('every soon path in the code names a known phase', () {
      final bad = <String>[];
      final re = RegExp(r"soonPath\(\s*'([^']+)'");
      for (final f in _dartFiles(_lib)) {
        for (final m in re.allMatches(f.readAsStringSync())) {
          if (!{'p1', 'p2', 'p3', 'later'}.contains(m.group(1))) {
            bad.add('${f.path}: ${m.group(1)}');
          }
        }
        for (final m in RegExp(
          r"'/soon/(\w+)",
        ).allMatches(f.readAsStringSync())) {
          if (!{'p1', 'p2', 'p3', 'later'}.contains(m.group(1))) {
            bad.add('${f.path}: /soon/${m.group(1)}');
          }
        }
      }
      expect(bad, isEmpty);
    });
  });

  group('every entry point on the hub screens', () {
    // Screens made of tiles, rows and buttons that lead elsewhere.
    const hubs = [
      '/home',
      '/explore',
      '/profile',
      '/passport',
      '/activity',
      '/settings',
      '/opportunities',
      '/learning',
      '/community',
      '/portfolio',
      '/saved',
      '/settings/membership',
      '/settings/help',
    ];

    final tappable = find.byWidgetPredicate(
      (w) =>
          (w is InkWell && w.onTap != null) ||
          (w is GestureDetector && w.onTap != null),
      description: 'a tappable',
    );

    for (final path in hubs) {
      testWidgets('$path: each tap lands somewhere real', (t) async {
        final screen = phase1Screens.firstWhere((s) => s.path == path);
        var h = await openScreen(t, screen);
        final count = tappable.evaluate().length;
        expect(count, greaterThan(0), reason: '$path has nothing to tap');
        final problems = <String>[];
        for (var i = 0; i < count; i++) {
          // A fresh app for every tap, so one tap cannot change what the next one finds.
          await t.pumpWidget(const SizedBox());
          await t.pump(const Duration(seconds: 1));
          h = await openScreen(t, screen);
          final targets = tappable.evaluate().toList();
          if (i >= targets.length) break;
          await t.tap(tappable.at(i), warnIfMissed: false);
          await t.pumpAndSettle();
          final where = h.path;
          if (t.takeException() != null) problems.add('#$i threw at $where');
          if (find
                  .textContaining('no routes for location')
                  .evaluate()
                  .isNotEmpty ||
              find.text('Page Not Found').evaluate().isNotEmpty) {
            problems.add('#$i opened a missing route ($where)');
          }
          if (where.startsWith('/soon/')) {
            final labelled =
                find.textContaining('Soon · P').evaluate().isNotEmpty ||
                find.text('Soon · Later').evaluate().isNotEmpty;
            if (!labelled) problems.add('#$i /soon without label ($where)');
          }
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  });

  group('no hard-coded sample data in UI code', () {
    // People and titles from the dev demo seed (apps/backend/prisma/seed) and the prototype. UI text comes from
    // the API or from l10n; none of these may be written into code or strings.
    const forbidden = [
      'Nia Wairimu',
      'Amani Otieno',
      'Zuri Mwangi',
      'Kiptoo Langat',
      'Wanjiku Njeri',
      'Emerging Creatives Grant',
      'Mama Mboga',
      'Nairobi Creative Fund',
      'Build a Portfolio That Gets You Hired',
      'demo.atarah',
      'example.com',
      'lorem ipsum',
    ];

    test('lib/ has none of the demo names or titles', () {
      final hits = <String>[];
      for (final f in _dartFiles(_lib)) {
        // The component gallery is a developer tool, only reachable in dev builds (Routes.devGallery).
        if (f.path.contains('gallery')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // A comment explaining a format may give an example; code and strings may not.
          if (line.trimLeft().startsWith('//')) continue;
          for (final bad in forbidden) {
            // An input's format hint ("name@example.com") is a placeholder, not data.
            if (bad == 'example.com' && line.contains('hint:')) continue;
            if (line.toLowerCase().contains(bad.toLowerCase())) {
              hits.add('${f.path}:${i + 1}: $bad');
            }
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('the l10n strings have none either', () {
      final arb = File('lib/core/l10n/app_en.arb').readAsStringSync();
      final hits = [
        for (final bad in forbidden)
          if (arb.toLowerCase().contains(bad.toLowerCase())) bad,
      ];
      expect(hits, isEmpty);
    });
  });
}
