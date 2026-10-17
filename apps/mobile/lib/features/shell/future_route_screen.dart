import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';

/// Maps a `/soon/:phase` route onto [AtFutureScreen]. Every entry point to a feature that is not built yet
/// opens this, labelled with its phase ("Soon · P2"). It is the only allowed placeholder: no dead buttons.
class FutureRouteScreen extends StatelessWidget {
  const FutureRouteScreen({
    super.key,
    required this.phase,
    this.name,
    this.showBack = true,
    this.onBack,
  });

  /// `p1`, `p2`, `p3` or `later`.
  final String phase;
  final String? name;
  final bool showBack;
  final VoidCallback? onBack;

  static AtFuturePhase parsePhase(String raw) => switch (raw.toLowerCase()) {
    'p1' => AtFuturePhase.p1,
    'p2' => AtFuturePhase.p2,
    'p3' => AtFuturePhase.p3,
    _ => AtFuturePhase.later,
  };

  @override
  Widget build(BuildContext context) {
    return AtFutureScreen(
      phase: parsePhase(phase),
      featureName: name,
      showBack: showBack,
      onBack: onBack,
    );
  }
}
