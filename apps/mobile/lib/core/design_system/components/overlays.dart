import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';
import 'buttons.dart';
import 'inputs.dart';

/// Bottom sheet: 28 radius top corners, grabber, scrim `rgba(21,19,61,.45)`, sheet shadow.
Future<T?> showAtBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
  bool showGrabber = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    barrierColor: AtColors.scrimSheet,
    builder: (ctx) => AtSheetFrame(
      title: title,
      showGrabber: showGrabber,
      child: builder(ctx),
    ),
  );
}

/// The visual frame of a bottom sheet. Exposed so sheets can be rendered in tests and the gallery.
class AtSheetFrame extends StatelessWidget {
  const AtSheetFrame({
    super.key,
    required this.child,
    this.title,
    this.showGrabber = true,
  });

  final Widget child;
  final String? title;
  final bool showGrabber;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: inset),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AtColors.white,
            borderRadius: AtRadii.sheetTop,
            boxShadow: AtShadows.sheet,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                10,
                AtSpacing.gutter,
                AtSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showGrabber)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: const BoxDecoration(
                          color: AtColors.toggleOff,
                          borderRadius: AtRadii.pill,
                        ),
                      ),
                    ),
                  if (title != null) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: AtTextStyles.sectionTitle.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered modal: 26 radius, scrim `.5`, modal shadow.
Future<T?> showAtModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: AtColors.scrimModal,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AtSpacing.gutter,
        vertical: 24,
      ),
      child: AtModalFrame(child: builder(ctx)),
    ),
  );
}

class AtModalFrame extends StatelessWidget {
  const AtModalFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: AtColors.white,
        borderRadius: AtRadii.modal,
        boxShadow: AtShadows.modal,
      ),
      child: SingleChildScrollView(child: child),
    );
  }
}

/// Result of the "You're leaving Atarah" modal.
class LeavingAtarahChoice {
  const LeavingAtarahChoice({
    required this.continueToSite,
    required this.trackAsApplied,
  });

  final bool continueToSite;
  final bool trackAsApplied;
}

/// Content of the leaving-Atarah modal. Names the destination domain and states that Atarah does not process
/// the external application. "Track as applied" defaults on and is only honoured if it stays ticked.
class AtLeavingAtarahModal extends StatefulWidget {
  const AtLeavingAtarahModal({
    super.key,
    required this.domain,
    required this.onResult,
    this.showTrackOption = true,
  });

  final String domain;
  final ValueChanged<LeavingAtarahChoice> onResult;
  final bool showTrackOption;

  @override
  State<AtLeavingAtarahModal> createState() => _AtLeavingAtarahModalState();
}

class _AtLeavingAtarahModalState extends State<AtLeavingAtarahModal> {
  bool _track = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: AtIconTileLarge(
            icon: LucideIcons.externalLink,
            tone: AtTone.primary,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.leavingTitle,
            textAlign: TextAlign.center,
            style: AtTextStyles.detailTitle.copyWith(color: AtColors.ink),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.leavingBody(widget.domain),
          textAlign: TextAlign.center,
          style: AtTextStyles.body.copyWith(color: AtColors.body),
        ),
        if (widget.showTrackOption) ...[
          const SizedBox(height: 14),
          AtCheckbox(
            value: _track,
            onChanged: (v) => setState(() => _track = v),
            label: l10n.leavingTrack,
          ),
        ],
        const SizedBox(height: 14),
        AtButton(
          label: l10n.leavingContinue,
          trailingIcon: LucideIcons.externalLink,
          onPressed: () => widget.onResult(
            LeavingAtarahChoice(continueToSite: true, trackAsApplied: _track),
          ),
        ),
        const SizedBox(height: 4),
        AtButton(
          label: l10n.leavingStay,
          variant: AtButtonVariant.tertiary,
          onPressed: () => widget.onResult(
            const LeavingAtarahChoice(
              continueToSite: false,
              trackAsApplied: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens [AtLeavingAtarahModal]. Returns null if dismissed.
Future<LeavingAtarahChoice?> showLeavingAtarahModal(
  BuildContext context, {
  required String domain,
  bool showTrackOption = true,
}) {
  return showAtModal<LeavingAtarahChoice>(
    context: context,
    builder: (ctx) => AtLeavingAtarahModal(
      domain: domain,
      showTrackOption: showTrackOption,
      onResult: (r) => Navigator.of(ctx).pop(r),
    ),
  );
}

/// 64px icon tile used at the top of modals and empty states.
class AtIconTileLarge extends StatelessWidget {
  const AtIconTileLarge({
    super.key,
    required this.icon,
    this.tone = AtTone.primary,
  });

  final IconData icon;
  final AtTone tone;

  @override
  Widget build(BuildContext context) {
    final c = tone.colors;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: c.bg, borderRadius: AtRadii.panel),
      child: Icon(icon, size: 28, color: c.fg),
    );
  }
}

/// Sheet content for AI help: header with the AI disc, the "AI-assisted" label, a body slot, the
/// disclaimer, and Discard / Apply. AI output is never written anywhere until the member taps Apply.
class AtAiSheet extends StatelessWidget {
  const AtAiSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onApply,
    required this.onDiscard,
    this.testMode = false,
    this.applying = false,
    this.applyLabel,
    this.disclaimer,
  });

  final String title;
  final Widget child;
  final VoidCallback? onApply;
  final VoidCallback onDiscard;

  /// Shown when the fake dev provider is generating, so nobody mistakes it for real AI output.
  final bool testMode;
  final bool applying;
  final String? applyLabel;
  final String? disclaimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AtGradients.ai,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 20,
                color: AtColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: AtTextStyles.sectionTitleSm.copyWith(
                        color: AtColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    testMode ? l10n.aiTestMode : l10n.aiAssisted,
                    style: AtTextStyles.meta.copyWith(
                      color: testMode
                          ? AtColors.warningStrong
                          : AtColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(LucideIcons.info, size: 14, color: AtColors.muted),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                disclaimer ?? l10n.aiDisclaimer,
                style: AtTextStyles.meta.copyWith(color: AtColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AtButton(
                label: l10n.aiDiscard,
                variant: AtButtonVariant.secondary,
                onPressed: onDiscard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AtButton(
                label: applyLabel ?? l10n.aiApply,
                onPressed: onApply,
                loading: applying,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
