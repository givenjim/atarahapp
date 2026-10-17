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

/// Text on the surfaces it is actually drawn on. Body text needs 4.5:1; bold text of 14px or more is
/// "large" and needs 3:1. Decorative colours (`faint`, `*Fg` icon colours) are intentionally not listed:
/// they are never used for text.
void main() {
  final tones = {
    'primary': AtTone.primary.colors,
    'success': AtTone.success.colors,
    'warning': AtTone.warning.colors,
    'pink': AtTone.pink.colors,
    'info': AtTone.info.colors,
    'purple': AtTone.purple.colors,
    'amber': AtTone.amber.colors,
    'neutral': AtTone.neutral.colors,
  };

  group('body text on its surfaces is at least 4.5:1', () {
    final surfaces = {
      'white': AtColors.white,
      'softTile': AtColors.softTile,
      'inputFill': AtColors.inputFill,
      'segmentedTrack': AtColors.segmentedTrack,
    };
    for (final fg in {
      'ink': AtColors.ink,
      'body': AtColors.body,
      'longForm': AtColors.longForm,
      'muted': AtColors.muted,
    }.entries) {
      for (final bg in surfaces.entries) {
        test('${fg.key} on ${bg.key}', () {
          expect(contrast(fg.value, bg.value), greaterThanOrEqualTo(4.5));
        });
      }
    }
    test('muted on a tinted unread row (tint3)', () {
      expect(
        contrast(AtColors.muted, AtColors.tint3),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('tone text on its own tint and on white', () {
    for (final e in tones.entries) {
      test('${e.key}: strong on bg', () {
        expect(contrast(e.value.strong, e.value.bg), greaterThanOrEqualTo(4.5));
      });
      test('${e.key}: strong on white', () {
        expect(
          contrast(e.value.strong, AtColors.white),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });

  group('text on filled controls', () {
    test(
      'white on primary',
      () => expect(
        contrast(AtColors.white, AtColors.primary),
        greaterThanOrEqualTo(4.5),
      ),
    );
    test(
      'white on the darker CTA gradient stop',
      () => expect(
        contrast(AtColors.white, const Color(0xFF5A46EE)),
        greaterThanOrEqualTo(4.5),
      ),
    );
    test('white on the lighter CTA gradient stop (bold 15px = large text)', () {
      expect(
        contrast(AtColors.white, AtColors.primaryLight),
        greaterThanOrEqualTo(3.0),
      );
    });
    test(
      'white on ink (offline banner)',
      () => expect(
        contrast(AtColors.white, AtColors.ink),
        greaterThanOrEqualTo(4.5),
      ),
    );
    test(
      'primary on tint1 (selected states)',
      () => expect(
        contrast(AtColors.primary, AtColors.tint1),
        greaterThanOrEqualTo(4.5),
      ),
    );
    test(
      'pro text on the pro pill',
      () => expect(
        contrast(AtColors.proText, const Color(0xFFFBD38D)),
        greaterThanOrEqualTo(4.5),
      ),
    );
    test(
      'white on the dark hero card',
      () => expect(
        contrast(AtColors.white, const Color(0xFF25206A)),
        greaterThanOrEqualTo(4.5),
      ),
    );
  });

  test('the checker itself: black on white is 21:1', () {
    expect(
      contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
  });
}
