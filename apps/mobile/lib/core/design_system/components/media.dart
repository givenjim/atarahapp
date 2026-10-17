import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../tokens.g.dart';
import 'at_tap_target.dart';
import 'avatars_progress.dart';
import 'surfaces.dart';

/// Dashed "add" tile (add project, add media).
class AtUploadZone extends StatelessWidget {
  const AtUploadZone({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = LucideIcons.imagePlus,
    this.height = 120,
    this.hint,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AtColors.dashedBorder,
          radius: AtRadii.cardLgValue,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AtRadii.cardLg,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AtIconTile(icon: icon, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: AtTextStyles.chip.copyWith(
                        color: AtColors.primary,
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint!,
                        style: AtTextStyles.meta.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

enum AtMediaTileState { ready, uploading, failed }

/// Thumbnail of an uploaded (or uploading) file with remove and retry. Failed uploads offer retry.
class AtMediaTile extends StatelessWidget {
  const AtMediaTile({
    super.key,
    this.image,
    this.state = AtMediaTileState.ready,
    this.progress,
    this.onRemove,
    this.onRetry,
    this.size = 96,
    this.icon,
    this.semanticLabel,
  });

  final ImageProvider? image;
  final AtMediaTileState state;

  /// 0..1 while uploading.
  final double? progress;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final double size;

  /// Shown instead of an image for audio/video/documents.
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: size,
      height: size,
      // No clipping: the remove button overhangs the corner and its tap target must stay a full 48x48.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AtRadii.card,
              child: Container(
                color: AtColors.softTile,
                child: image != null
                    ? Image(
                        image: image!,
                        fit: BoxFit.cover,
                        semanticLabel: semanticLabel,
                      )
                    : Icon(
                        icon ?? LucideIcons.file,
                        size: 28,
                        color: AtColors.muted,
                      ),
              ),
            ),
          ),
          if (state == AtMediaTileState.uploading)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: AtRadii.card,
                child: ColoredBox(
                  color: const Color.fromRGBO(21, 19, 61, 0.45),
                  child: Center(
                    child: Semantics(
                      label: l10n.uploading(((progress ?? 0) * 100).round()),
                      child: AtProgressRing(
                        value: progress ?? 0,
                        size: 44,
                        strokeWidth: 4,
                        onDark: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (state == AtMediaTileState.failed)
            Positioned.fill(
              child: Semantics(
                button: true,
                label: l10n.uploadRetry,
                excludeSemantics: true,
                onTap: onRetry,
                child: GestureDetector(
                  onTap: onRetry,
                  child: const ClipRRect(
                    borderRadius: AtRadii.card,
                    child: ColoredBox(
                      color: Color.fromRGBO(198, 47, 99, 0.82),
                      child: Center(
                        child: Icon(
                          LucideIcons.refreshCw,
                          size: 24,
                          color: AtColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: -12,
              right: -12,
              child: AtTapTarget(
                minSize: 48,
                semanticLabel: l10n.remove,
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AtColors.ink,
                    shape: BoxShape.circle,
                    border: Border.all(color: AtColors.white, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 12,
                    color: AtColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
