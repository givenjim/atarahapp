import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/design_system/gallery/component_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

/// One golden per gallery entry, per appearance (light and dark), at 1x and 2x text scale, on a
/// 390 wide phone canvas. Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/design_system/golden_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    for (final entry in galleryEntries) {
      for (final scale in [1.0, 2.0]) {
        final suffix = scale == 1.0 ? '1x' : '2x';
        testWidgets('${entry.id} ${appearance.name} @ $suffix', (t) async {
          t.view.physicalSize = const Size(390, 4200);
          t.view.devicePixelRatio = 1.0;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);

          final key = GlobalKey();
          await t.pumpWidget(
            atApp(
              RepaintBoundary(
                key: key,
                child: GalleryPanel(
                  appearance: appearance,
                  child: Builder(builder: entry.builder),
                ),
              ),
              textScale: scale,
              appearance: appearance,
            ),
          );
          await t.pump();
          await expectLater(
            find.byKey(key),
            matchesGoldenFile(
              'goldens/${entry.id}.${appearance.name}.$suffix.png',
            ),
          );
        });
      }
    }
  }
}
