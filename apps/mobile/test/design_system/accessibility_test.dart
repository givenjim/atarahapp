import 'package:atarah/core/design_system/gallery/component_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

/// Accessibility bar (Master Prompt section 7.5), checked against every gallery entry:
///  * text scales to 200% without overflow or clipping errors,
///  * every tap target is at least 48x48,
///  * every tappable control has a semantic label,
///  Text contrast is verified per token pair in contrast_test.dart (Flutter's pixel-sampling guideline is
///  unreliable with anti-aliased small text).
void main() {
  for (final entry in galleryEntries) {
    group('gallery: ${entry.id}', () {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'renders without overflow at ${(scale * 100).round()}% text',
          (t) async {
            await t.pumpAt(
              Builder(builder: entry.builder),
              textScale: scale,
              size: const Size(390, 3000),
            );
            expect(t.takeException(), isNull);
          },
        );
      }

      testWidgets('tap targets are >= 48x48 and controls are labelled', (
        t,
      ) async {
        final handle = t.ensureSemantics();
        await t.pumpAt(
          Builder(builder: entry.builder),
          size: const Size(390, 3000),
        );
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    });
  }
}
