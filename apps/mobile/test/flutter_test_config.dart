import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/tolerant_golden_comparator.dart';

/// Applied to every test file in this directory.
///
/// Flutter tests replace every font with a block-glyph test font unless real fonts are loaded, which
/// would make goldens meaningless. Load the bundled Plus Jakarta Sans and the Lucide icon font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  installTolerantGoldenComparator();
  await _loadFont('Plus Jakarta Sans', const [
    'assets/fonts/PlusJakartaSans-Regular.ttf',
    'assets/fonts/PlusJakartaSans-Medium.ttf',
    'assets/fonts/PlusJakartaSans-SemiBold.ttf',
    'assets/fonts/PlusJakartaSans-Bold.ttf',
    'assets/fonts/PlusJakartaSans-ExtraBold.ttf',
  ]);
  await _loadFont('packages/lucide_icons_flutter/Lucide', const [
    'packages/lucide_icons_flutter/assets/lucide.ttf',
  ]);
  await testMain();
}

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final a in assets) {
    loader.addFont(rootBundle.load(a));
  }
  await loader.load();
}
