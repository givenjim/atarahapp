import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.g.dart';
import 'at_tap_target.dart';

enum AtAvatarShape { circle, rounded }

/// Avatar in the prototype sizes. Falls back to initials when there is no image.
/// With [progress] set it draws a completion ring and a percentage badge (My profile).
class AtAvatar extends StatelessWidget {
  const AtAvatar({
    super.key,
    required this.name,
    this.image,
    this.size = 48,
    this.shape = AtAvatarShape.circle,
    this.progress,
    this.semanticLabel,
  });

  final String name;
  final ImageProvider? image;
  final double size;
  final AtAvatarShape shape;

  /// 0..1. Draws the ring and the badge.
  final double? progress;
  final String? semanticLabel;

  static const double xs = 28;
  static const double sm = 40;
  static const double md = 48;
  static const double lg = 72;
  static const double xl = 96;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  BorderRadius get _radius => shape == AtAvatarShape.circle
      ? BorderRadius.circular(size)
      : BorderRadius.circular(size * 0.25);

  @override
  Widget build(BuildContext context) {
    final ringWidth = progress != null ? 3.0 : 0.0;
    final inner = size - (progress != null ? 12 : 0);

    Widget face = Container(
      width: inner,
      height: inner,
      decoration: BoxDecoration(
        gradient: image == null ? AtGradients.ai : null,
        borderRadius: shape == AtAvatarShape.circle
            ? BorderRadius.circular(inner)
            : BorderRadius.circular(inner * 0.25),
        image: image == null
            ? null
            : DecorationImage(image: image!, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(
              _initials,
              style: AtTextStyles.cardTitle.copyWith(
                color: AtColors.white,
                fontSize: inner * 0.36,
              ),
            )
          : null,
    );

    if (progress != null) {
      final pct = (progress!.clamp(0, 1) * 100).round();
      face = SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: progress!.clamp(0, 1),
                strokeWidth: ringWidth + 1,
                track: AtColors.progressTrack,
                color: AtColors.primary,
                rounded: shape == AtAvatarShape.rounded,
              ),
            ),
            face,
            Positioned(
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AtColors.primary,
                  borderRadius: AtRadii.pill,
                  border: Border.all(color: AtColors.white, width: 2),
                ),
                child: Text(
                  '$pct%',
                  style: AtTextStyles.chipSm.copyWith(
                    color: AtColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      image: true,
      label:
          semanticLabel ??
          (progress == null
              ? name
              : '$name, profile ${(progress! * 100).round()}% complete'),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: _radius,
        clipBehavior: Clip.none,
        child: face,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.track,
    required this.color,
    required this.rounded,
  });

  final double progress;
  final double strokeWidth;
  final Color track;
  final Color color;
  final bool rounded;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final deflated = rect.deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = track;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    if (rounded) {
      final rrect = RRect.fromRectAndRadius(
        deflated,
        Radius.circular(size.width * 0.3),
      );
      canvas.drawRRect(rrect, trackPaint);
      final path = Path()..addRRect(rrect);
      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        progressPaint,
      );
    } else {
      canvas.drawOval(deflated, trackPaint);
      canvas.drawArc(
        deflated,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.rounded != rounded;
}

/// Linear progress (lesson progress, completion, upload).
class AtProgressBar extends StatelessWidget {
  const AtProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.gradient,
    this.semanticLabel,
  });

  /// 0..1
  final double value;
  final double height;
  final Color? color;
  final Gradient? gradient;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(v * 100).round()}%',
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: AtRadii.pill,
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AtColors.progressTrack),
              ),
              FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: gradient == null
                        ? (color ?? AtColors.primary)
                        : null,
                    gradient:
                        gradient ?? (color == null ? AtGradients.cta : null),
                    borderRadius: AtRadii.pill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular progress with a centre label (Continue learning ring).
class AtProgressRing extends StatelessWidget {
  const AtProgressRing({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 6,
    this.label,
    this.onDark = false,
    this.semanticLabel,
  });

  final double value;
  final double size;
  final double strokeWidth;

  /// Defaults to the percentage.
  final String? label;
  final bool onDark;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(v * 100).round()}%',
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: v,
                strokeWidth: strokeWidth,
                track: onDark
                    ? const Color.fromRGBO(255, 255, 255, 0.2)
                    : AtColors.progressTrack,
                color: onDark ? AtColors.white : AtColors.primary,
                rounded: false,
              ),
            ),
            Text(
              label ?? '${(v * 100).round()}%',
              style: AtTextStyles.chip.copyWith(
                color: onDark ? AtColors.white : AtColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented step indicator (onboarding progress, lesson segments).
class AtStepper extends StatelessWidget {
  const AtStepper({
    super.key,
    required this.steps,
    required this.current,
    this.semanticLabel,
  });

  final int steps;

  /// 1-based current step. Steps before it are filled.
  final int current;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: '$current / $steps',
      child: Row(
        children: [
          for (var i = 1; i <= steps; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: atDuration(context, AtMotion.base),
                height: 5,
                decoration: BoxDecoration(
                  gradient: i <= current ? AtGradients.cta : null,
                  color: i <= current ? null : AtColors.progressTrack,
                  borderRadius: AtRadii.pill,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
