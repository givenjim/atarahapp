import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.g.dart';

enum AtBannerTone { error, success, info }

/// Inline message under a form: the sign-in error ("That password doesn't match this account…"), "Code sent."
/// and similar. Colour is never the only signal: each tone has its own icon and the text states the news.
class AtInlineBanner extends StatelessWidget {
  const AtInlineBanner({
    super.key,
    required this.message,
    this.tone = AtBannerTone.error,
    this.action,
  });

  final String message;
  final AtBannerTone tone;

  /// Optional action shown under the message, such as "Sign in instead".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (tone) {
      AtBannerTone.error => (
        AtColors.pinkBg,
        AtColors.pinkStrong,
        LucideIcons.circleAlert,
      ),
      AtBannerTone.success => (
        AtColors.successBg,
        AtColors.successStrong,
        LucideIcons.circleCheck,
      ),
      AtBannerTone.info => (
        AtColors.tint1,
        AtColors.primaryPressed,
        LucideIcons.info,
      ),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: AtRadii.tileLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 18, color: fg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: AtTextStyles.bodySm.copyWith(color: fg)),
                  if (action != null) ...[const SizedBox(height: 6), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
