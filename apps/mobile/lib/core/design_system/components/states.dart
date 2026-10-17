import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';
import 'at_tap_target.dart';
import 'buttons.dart';
import 'chips_tags.dart';
import 'surfaces.dart';

/// Layout-preserving placeholder. Skeletons replace full-screen spinners so the page does not jump.
/// The shimmer stops under "reduce motion".
class AtSkeleton extends StatefulWidget {
  const AtSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
  });

  const AtSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<AtSkeleton> createState() => _AtSkeletonState();
}

class _AtSkeletonState extends State<AtSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (atReduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loading,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.circle
                  ? null
                  : BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2 * t - 0.5, 0),
                end: Alignment(-1.0 + 2 * t + 0.5, 0),
                colors: const [
                  AtColors.progressTrack,
                  AtColors.softTile,
                  AtColors.progressTrack,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Empty state with a next action (the four prototype variants: portfolio, opportunities, learning, mentorship).
class AtEmptyState extends StatelessWidget {
  const AtEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.tone = AtTone.primary,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String? body;
  final AtTone tone;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final c = tone.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [c.bg, AtColors.white],
                  stops: const [0, 0.7],
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 38, color: c.fg),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AtTextStyles.sectionTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AtColors.ink,
                ),
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
              ),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: 22),
              AtButton(
                label: ctaLabel!,
                onPressed: onCta,
                size: AtButtonSize.md,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Which side failed. Tells the member whether the problem is Atarah, an external site, or a dead link.
enum AtErrorVariant { atarah, external, invalidLink }

class AtErrorState extends StatelessWidget {
  const AtErrorState({
    super.key,
    this.variant = AtErrorVariant.atarah,
    this.title,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.onContactSupport,
    this.supportLabel,
  });

  final AtErrorVariant variant;
  final String? title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final VoidCallback? onContactSupport;
  final String? supportLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (
      icon,
      tone,
      defaultTitle,
      defaultBody,
      ctaIcon,
      defaultCta,
    ) = switch (variant) {
      AtErrorVariant.atarah => (
        LucideIcons.cloudAlert,
        AtTone.primary,
        l10n.errorAtarahTitle,
        l10n.errorAtarahBody,
        LucideIcons.refreshCw,
        l10n.retry,
      ),
      AtErrorVariant.external => (
        LucideIcons.globe,
        AtTone.warning,
        l10n.errorExternalTitle,
        l10n.errorExternalBody,
        LucideIcons.arrowLeft,
        l10n.back,
      ),
      AtErrorVariant.invalidLink => (
        LucideIcons.link2Off,
        AtTone.pink,
        l10n.errorInvalidLinkTitle,
        l10n.errorInvalidLinkBody,
        LucideIcons.search,
        l10n.back,
      ),
    };
    final c = tone.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 42, color: c.fg),
            ),
            const SizedBox(height: 22),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                title ?? defaultTitle,
                textAlign: TextAlign.center,
                style: AtTextStyles.sectionTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AtColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body ?? defaultBody,
              textAlign: TextAlign.center,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
            ),
            if (onCta != null) ...[
              const SizedBox(height: 22),
              AtButton(
                label: ctaLabel ?? defaultCta,
                icon: ctaIcon,
                onPressed: onCta,
                size: AtButtonSize.md,
                fullWidth: false,
              ),
            ],
            if (onContactSupport != null) ...[
              const SizedBox(height: 6),
              AtButton(
                label: supportLabel ?? l10n.contactSupport,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.md,
                fullWidth: false,
                onPressed: onContactSupport,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Global offline banner: "You're offline. Saved content is still available."
class AtOfflineBanner extends StatelessWidget {
  const AtOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      label: l10n.offlineBanner,
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: const BoxDecoration(
          color: AtColors.ink,
          borderRadius: AtRadii.tileLg,
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.wifiOff, size: 15, color: AtColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.offlineBanner,
                style: AtTextStyles.metaSm.copyWith(color: AtColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of a premium feature for members without the entitlement. Explains what it does, why it
/// matters and how to get it. Premium is enforced by the backend; this only presents the denial.
class AtPremiumGate extends StatelessWidget {
  const AtPremiumGate({
    super.key,
    required this.feature,
    required this.whatItDoes,
    required this.whyItMatters,
    required this.howToGet,
    required this.priceLabel,
    required this.onSeePro,
    this.onCheckScholarship,
  });

  final String feature;
  final String whatItDoes;
  final String whyItMatters;
  final String howToGet;

  /// Formatted price from settings, e.g. "KES 1,200/month". Never hard-coded in widgets.
  final String priceLabel;
  final VoidCallback onSeePro;
  final VoidCallback? onCheckScholarship;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AtSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: AtGradients.pro,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                LucideIcons.crown,
                size: 38,
                color: AtColors.proText,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Semantics(
            header: true,
            child: Text(
              l10n.premiumGateTitle(feature),
              textAlign: TextAlign.center,
              style: AtTextStyles.detailTitle.copyWith(color: AtColors.ink),
            ),
          ),
          const SizedBox(height: 18),
          _Block(
            title: l10n.premiumWhatItDoes,
            body: whatItDoes,
            icon: LucideIcons.sparkles,
          ),
          const SizedBox(height: 10),
          _Block(
            title: l10n.premiumWhyItMatters,
            body: whyItMatters,
            icon: LucideIcons.target,
          ),
          const SizedBox(height: 10),
          _Block(
            title: l10n.premiumHowToGet,
            body: howToGet,
            icon: LucideIcons.keyRound,
          ),
          const SizedBox(height: 20),
          AtButton(label: l10n.premiumSeePro(priceLabel), onPressed: onSeePro),
          if (onCheckScholarship != null)
            AtButton(
              label: l10n.premiumScholarship,
              variant: AtButtonVariant.tertiary,
              onPressed: onCheckScholarship,
            ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      padding: const EdgeInsets.all(14),
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtIconTile(icon: icon, size: 36, tone: AtTone.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Which delivery phase an unbuilt feature belongs to.
enum AtFuturePhase { p1, p2, p3, later }

/// Entry points to features scheduled for a later phase open this screen instead of doing nothing.
/// It is the only allowed placeholder: no dead buttons, no fake success.
class AtFutureScreen extends StatelessWidget {
  const AtFutureScreen({
    super.key,
    required this.phase,
    this.featureName,
    this.onBack,
    this.showBack = true,
  });

  final AtFuturePhase phase;

  /// Name of the feature the member tapped, shown as the title when available.
  final String? featureName;
  final VoidCallback? onBack;

  /// Tab roots have nothing to go back to, so they hide the back controls.
  final bool showBack;

  static String labelFor(AppLocalizations l10n, AtFuturePhase phase) =>
      switch (phase) {
        AtFuturePhase.p1 => l10n.soonPhase(1),
        AtFuturePhase.p2 => l10n.soonPhase(2),
        AtFuturePhase.p3 => l10n.soonPhase(3),
        AtFuturePhase.later => l10n.soonLater,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        child: Column(
          children: [
            AtTopBar(
              onBack: showBack
                  ? (onBack ?? () => Navigator.of(context).maybePop())
                  : null,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: AtGradients.ai,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          LucideIcons.hourglass,
                          size: 40,
                          color: AtColors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      AtTag(
                        label: labelFor(l10n, phase),
                        tone: AtTone.primary,
                        icon: LucideIcons.clock,
                      ),
                      const SizedBox(height: 14),
                      Semantics(
                        header: true,
                        child: Text(
                          featureName ?? l10n.futureTitle,
                          textAlign: TextAlign.center,
                          style: AtTextStyles.subTitle.copyWith(
                            color: AtColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.futureBody,
                        textAlign: TextAlign.center,
                        style: AtTextStyles.body.copyWith(color: AtColors.body),
                      ),
                      if (showBack) ...[
                        const SizedBox(height: 24),
                        AtButton(
                          label: l10n.futureBack,
                          variant: AtButtonVariant.secondary,
                          size: AtButtonSize.md,
                          fullWidth: false,
                          onPressed:
                              onBack ?? () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
