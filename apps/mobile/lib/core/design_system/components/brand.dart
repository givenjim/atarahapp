import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tokens.g.dart';

/// "ATARA" + "H" in the primary colour, weight 800, with the tagline "CREATE · CONNECT · GROW" (0.14em tracking).
class AtWordmark extends StatelessWidget {
  const AtWordmark({
    super.key,
    this.color = AtColors.ink,
    this.accent = AtColors.primary,
    this.size = 22,
    this.showTagline = true,
    this.taglineColor = AtColors.muted,
    this.alignment = CrossAxisAlignment.start,
  });

  final Color color;
  final Color accent;
  final double size;
  final bool showTagline;
  final Color taglineColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.appName,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'ATARA',
                  style: TextStyle(color: color),
                ),
                TextSpan(
                  text: 'H',
                  style: TextStyle(color: accent),
                ),
              ],
            ),
            style: AtTextStyles.wordmark.copyWith(
              fontSize: size,
              letterSpacing: -0.01 * size,
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: 2),
            Text(
              l10n.tagline,
              style: AtTextStyles.tagline.copyWith(
                color: taglineColor,
                fontSize: (size * 0.5).clamp(10, 14).toDouble(),
                letterSpacing: 0.14 * (size * 0.5).clamp(10, 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
