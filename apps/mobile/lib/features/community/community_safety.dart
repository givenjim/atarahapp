import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'community_common.dart';
import 'community_providers.dart';

/// "Delete this?", with the consequences spelled out. True when the member confirms.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final yes = await showAtBottomSheet<bool>(
    context: context,
    title: title,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(body, style: AtTextStyles.body.copyWith(color: ctx.at.body)),
        const SizedBox(height: 20),
        AtButton(
          label: confirmLabel,
          variant: destructive
              ? AtButtonVariant.destructive
              : AtButtonVariant.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        const SizedBox(height: 8),
        AtButton(
          label: l10n.cfdCancel,
          variant: AtButtonVariant.tertiary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    ),
  );
  return yes ?? false;
}

/// A sheet with a text box for changing something the member wrote. Returns the new text, or null.
Future<String?> showEditTextSheet(
  BuildContext context, {
  required String title,
  required String initial,
  required int maxLength,
  required Future<void> Function(String text) onSave,
}) => showAtBottomSheet<String>(
  context: context,
  title: title,
  builder: (_) =>
      _EditTextSheet(initial: initial, maxLength: maxLength, onSave: onSave),
);

class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.initial,
    required this.maxLength,
    required this.onSave,
  });

  final String initial;
  final int maxLength;
  final Future<void> Function(String text) onSave;

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final _controller = TextEditingController(text: widget.initial);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text == widget.initial.trim()) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(text);
      if (mounted) Navigator.of(context).pop(text);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = communityErrorMessage(AppLocalizations.of(context), e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(
          controller: _controller,
          hint: l10n.cfdBodyHint,
          minLines: 3,
          maxLines: 8,
          maxLength: widget.maxLength,
          showCounter: true,
          enabled: !_saving,
          keyboardType: TextInputType.multiline,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        AtButton(
          label: l10n.cfdSaveChanges,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

String reportReasonLabel(AppLocalizations l10n, ReportReason r) => switch (r) {
  ReportReason.inappropriate => l10n.cfdReasonInappropriate,
  ReportReason.harassment => l10n.cfdReasonHarassment,
  ReportReason.scam => l10n.cfdReasonScam,
  ReportReason.misleading => l10n.cfdReasonMisleading,
  ReportReason.impersonation => l10n.cfdReasonImpersonation,
  ReportReason.ipInfringement => l10n.cfdReasonIp,
  ReportReason.other => l10n.cfdReasonOther,
  ReportReason.$unknown => l10n.cfdReasonOther,
};

/// Report flow: the reason sheet (with an optional note), then a confirmation that explains what happens
/// next. True once the report has been sent.
Future<bool> showReportFlow(
  BuildContext context, {
  required ReportTargetType targetType,
  required String targetId,
}) async {
  final l10n = AppLocalizations.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final sent = await showAtBottomSheet<bool>(
    context: context,
    title: l10n.cfdReportTitle,
    builder: (_) => _ReportSheet(
      onSubmit: (reason, note) => container
          .read(communityRepositoryProvider)
          .report(
            targetType: targetType,
            targetId: targetId,
            reason: reason,
            note: note,
          ),
    ),
  );
  if (sent != true || !context.mounted) return false;
  await showAtBottomSheet<void>(
    context: context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: AtIconTileLarge(
            icon: LucideIcons.shieldCheck,
            tone: AtTone.success,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.cfdReportDoneTitle,
            textAlign: TextAlign.center,
            style: AtTextStyles.sectionTitle.copyWith(color: ctx.at.ink),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.cfdReportDoneBody,
          textAlign: TextAlign.center,
          style: AtTextStyles.body.copyWith(color: ctx.at.body),
        ),
        const SizedBox(height: 20),
        AtButton(label: l10n.cfdDone, onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
  return true;
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.onSubmit});

  final Future<void> Function(ReportReason reason, String? note) onSubmit;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = [
    ReportReason.inappropriate,
    ReportReason.harassment,
    ReportReason.scam,
    ReportReason.misleading,
    ReportReason.impersonation,
    ReportReason.ipInfringement,
    ReportReason.other,
  ];

  final _note = TextEditingController();
  ReportReason? _reason;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSubmit(reason, _note.text);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = communityErrorMessage(AppLocalizations.of(context), e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cfdReportIntro,
          style: AtTextStyles.body.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 14),
        for (final r in _reasons) ...[
          AtRadioCard(
            title: reportReasonLabel(l10n, r),
            selected: _reason == r,
            onTap: _sending ? null : () => setState(() => _reason = r),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        AtTextField(
          controller: _note,
          label: l10n.cfdReportNoteLabel,
          hint: l10n.cfdReportNoteHint,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
          enabled: !_sending,
          keyboardType: TextInputType.multiline,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          AtInlineBanner(message: _error!, tone: AtBannerTone.error),
        ],
        const SizedBox(height: 16),
        AtButton(
          label: l10n.cfdReportSubmit,
          loading: _sending,
          onPressed: _reason == null || _sending ? null : _send,
        ),
      ],
    );
  }
}

/// Block flow: says what blocking does, blocks, then confirms with a way to undo. True when blocked and
/// the member kept it that way.
Future<bool> showBlockFlow(
  BuildContext context, {
  required String userId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmSheet(
    context,
    title: l10n.cfdBlockTitle(name),
    body: l10n.cfdBlockBody,
    confirmLabel: l10n.cfdBlockConfirm,
  );
  if (!confirmed || !context.mounted) return false;
  final container = ProviderScope.containerOf(context, listen: false);
  final repo = container.read(communityRepositoryProvider);
  void refreshFeeds() {
    container.read(postOverridesProvider.notifier).clear();
    container.invalidate(feedProvider);
  }

  try {
    await repo.blockMember(userId);
  } on Object catch (e) {
    if (context.mounted) showCommunityError(context, e);
    return false;
  }
  if (!context.mounted) {
    refreshFeeds();
    return true;
  }
  final undone = await showAtBottomSheet<bool>(
    context: context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: AtIconTileLarge(icon: LucideIcons.userX, tone: AtTone.neutral),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.cfdBlockedTitle(name),
            textAlign: TextAlign.center,
            style: AtTextStyles.sectionTitle.copyWith(color: ctx.at.ink),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.cfdBlockedBody,
          textAlign: TextAlign.center,
          style: AtTextStyles.body.copyWith(color: ctx.at.body),
        ),
        const SizedBox(height: 20),
        AtButton(
          label: l10n.cfdDone,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        const SizedBox(height: 8),
        AtButton(
          label: l10n.cfdUndoBlock,
          variant: AtButtonVariant.tertiary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  if (undone == true) {
    try {
      await repo.unblockMember(userId);
      if (context.mounted) {
        showCommunityNotice(context, l10n.cfdUnblocked(name));
      }
      return false;
    } on Object catch (e) {
      if (context.mounted) showCommunityError(context, e);
    }
  }
  // The feed is rebuilt without the blocked member's posts.
  refreshFeeds();
  return true;
}
