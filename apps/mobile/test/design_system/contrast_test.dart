import 'dart:math' as math;

import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _lin(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Spec values (Master Prompt 8.1 / 8.3) that fall just short of 4.5:1 for small text. They are kept
/// exactly as specified and listed here so the gap is visible instead of silently passing; each is
/// still asserted to stay above [_gapFloor]. Reported to the product owner as a decision (P1-M7).
const _gapFloor = 4.0;
const _knownGaps = <String>{
  'light:muted', // #77758F: 4.44:1 on white, 4.2:1 on Mist
  'dark:coralStrong on coralSurface', // #F04478 on #3A1838
  'dark:coral: strong on bg',
};

void _expectReadable(String key, Color fg, Color bg) {
  final ratio = contrast(fg, bg);
  if (_knownGaps.contains(key) ||
      _knownGaps.contains(key.split(' on ').first)) {
    expect(
      ratio,
      greaterThanOrEqualTo(_gapFloor),
      reason: 'known spec gap $key',
    );
  } else {
    expect(ratio, greaterThanOrEqualTo(4.5), reason: key);
  }
}

/// Token pairs from Master Prompt section 8.1 / 8.2 / 8.3, checked in both appearances.
/// Body text needs 4.5:1. Bold text of 14px or more is "large" and needs 3:1 (white on the CTA
/// gradient, 15.5/700 minimum). Decorative colours (`faint`, tone `fg` icon colours, borders) are
/// never used for text and are not listed.
void main() {
  final sets = <String, AtColors>{
    'light': AtColors.light,
    'dark': AtColors.dark,
  };

  for (final MapEntry(key: name, value: c) in sets.entries) {
    group(
      '[$name] body text on the surfaces it is drawn on is at least 4.5:1',
      () {
        final surfaces = {
          'background': c.background,
          'surface': c.surface,
          'raised': c.raised,
          'mist': c.mist,
          'inputFill': c.inputFill,
          'segmentedTrack': c.segmentedTrack,
        };
        final texts = {
          'ink': c.ink,
          'longForm': c.longForm,
          'body': c.body,
          'muted': c.muted,
        };
        for (final fg in texts.entries) {
          for (final bg in surfaces.entries) {
            test('${fg.key} on ${bg.key}', () {
              _expectReadable('$name:${fg.key}', fg.value, bg.value);
            });
          }
        }
        test('muted on primaryTintFaint (unread row)', () {
          _expectReadable('$name:muted', c.muted, c.primaryTintFaint);
        });
      },
    );

    group('[$name] tone text on its own tint and on the page', () {
      for (final tone in AtTone.values) {
        final t = c.tone(tone);
        test('${tone.name}: strong on bg', () {
          _expectReadable('$name:${tone.name}: strong on bg', t.strong, t.bg);
        });
        test('${tone.name}: strong on surface', () {
          expect(contrast(t.strong, c.surface), greaterThanOrEqualTo(4.5));
        });
      }
    });

    group('[$name] links and accents', () {
      test('primary on surface', () {
        expect(contrast(c.primary, c.surface), greaterThanOrEqualTo(4.5));
      });
      test('primary on background', () {
        expect(contrast(c.primary, c.background), greaterThanOrEqualTo(4.5));
      });
      test('primary on primaryTint (verified badge, selected states)', () {
        expect(contrast(c.primary, c.primaryTint), greaterThanOrEqualTo(4.5));
      });
      test('primary on primaryTintStrong (active tab pill)', () {
        expect(
          contrast(c.primary, c.primaryTintStrong),
          greaterThanOrEqualTo(4.5),
        );
      });
      test('coralStrong on coralSurface (destructive)', () {
        _expectReadable(
          '$name:coralStrong on coralSurface',
          c.coralStrong,
          c.coralSurface,
        );
      });
      test('tangerineStrong on tangerineSurface and amberSurface', () {
        expect(
          contrast(c.tangerineStrong, c.tangerineSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.amberStrong, c.amberSurface),
          greaterThanOrEqualTo(4.5),
        );
      });
      test('successStrong on successSurface', () {
        expect(
          contrast(c.successStrong, c.successSurface),
          greaterThanOrEqualTo(4.5),
        );
      });
      test('neutralText on neutralSurface', () {
        expect(
          contrast(c.neutralText, c.neutralSurface),
          greaterThanOrEqualTo(4.5),
        );
      });
    });

    group('[$name] text on filled controls', () {
      test('white on primaryFill (selected chip, toggle, badge)', () {
        expect(contrast(c.white, c.primaryFill), greaterThanOrEqualTo(4.5));
      });
      test('white on the darker CTA gradient stop (Indigo)', () {
        expect(contrast(c.white, AtBrand.indigo), greaterThanOrEqualTo(4.5));
      });
      test(
        'white on the lighter CTA gradient stop (Violet; bold 15px = large)',
        () {
          expect(contrast(c.white, AtBrand.violet), greaterThanOrEqualTo(3.0));
        },
      );
      test('white on the dark hero card gradient stops', () {
        for (final stop in c.darkCardGradient.colors) {
          expect(contrast(c.white, stop), greaterThanOrEqualTo(4.5));
        }
      });
    });
  }

  test('white on the splash gradient stops', () {
    for (final stop in AtGradients.splash.colors) {
      expect(contrast(AtColors.light.white, stop), greaterThanOrEqualTo(4.5));
    }
  });

  test('the checker itself: black on white is 21:1', () {
    expect(
      contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
  });
}
