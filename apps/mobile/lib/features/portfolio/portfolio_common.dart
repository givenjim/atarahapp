import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';

// ---- labels ----

String categoryLabel(AppLocalizations l10n, String? json) => switch (json) {
  'MEDIA' => l10n.pjCatMedia,
  'PUBLICATION' => l10n.pjCatPublication,
  'PERFORMANCE' => l10n.pjCatPerformance,
  _ => l10n.pjCatProject,
};

const projectCategories = ['PROJECT', 'MEDIA', 'PUBLICATION', 'PERFORMANCE'];

String projectVisibilityLabel(AppLocalizations l10n, String? json) =>
    switch (json) {
      'MEMBERS' => l10n.vsMembers,
      'PRIVATE' => l10n.vsPrivate,
      _ => l10n.vsPublic,
    };

const projectVisibilities = ['PUBLIC', 'MEMBERS', 'PRIVATE'];

String levelLabel(AppLocalizations l10n, String? json) => switch (json) {
  'BEGINNER' => l10n.skLevelBeginner,
  'INTERMEDIATE' => l10n.skLevelIntermediate,
  'ADVANCED' => l10n.skLevelAdvanced,
  'EXPERT' => l10n.skLevelExpert,
  _ => l10n.skLevelUnrated,
};

const skillLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'];

/// 0 for unrated, 1 to 4 for beginner to expert: how full the level bar is.
int levelRank(String? json) => switch (json) {
  'BEGINNER' => 1,
  'INTERMEDIATE' => 2,
  'ADVANCED' => 3,
  'EXPERT' => 4,
  _ => 0,
};

String achievementTypeLabel(AppLocalizations l10n, String? json) =>
    switch (json) {
      'CERTIFICATE' => l10n.acTypeCertificate,
      'FEATURE' => l10n.acTypeFeature,
      'SELECTION' => l10n.acTypeSelection,
      'NOMINATION' => l10n.acTypeNomination,
      _ => l10n.acTypeAward,
    };

const achievementTypes = [
  'AWARD',
  'CERTIFICATE',
  'FEATURE',
  'SELECTION',
  'NOMINATION',
];

IconData achievementIcon(String? json) => switch (json) {
  'CERTIFICATE' => LucideIcons.graduationCap,
  'FEATURE' => LucideIcons.newspaper,
  'SELECTION' => LucideIcons.badgeCheck,
  'NOMINATION' => LucideIcons.star,
  _ => LucideIcons.award,
};

String priceText(AppLocalizations l10n, ServiceDto s) {
  final f = NumberFormat.decimalPattern();
  return switch (s.priceType) {
    ServiceDtoPriceType.fixed when s.priceMin != null => l10n.svPriceFixed(
      f.format(s.priceMin),
    ),
    ServiceDtoPriceType.range when s.priceMin != null && s.priceMax != null =>
      l10n.svPriceRange(f.format(s.priceMin), f.format(s.priceMax)),
    _ => l10n.svPriceOnRequest,
  };
}

// ---- dates ----

/// `2026-03-14` to a date the member can read (March 2026).
String monthYear(BuildContext context, String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  if (d == null) return '';
  return DateFormat.yMMM(Localizations.localeOf(context).toString()).format(d);
}

String fullDate(BuildContext context, String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  if (d == null) return '';
  return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);
}

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ---- shared widgets ----

/// A date field that opens the calendar. Shows [value] (an ISO date) or the hint, and a clear button.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.firstDate,
    this.clearable = true,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final DateTime? firstDate;
  final bool clearable;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(value ?? '') ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(1970),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) onChanged(isoDay(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = value == null ? null : fullDate(context, value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AtTextStyles.label.copyWith(color: AtColors.ink)),
        const SizedBox(height: 6),
        AtTapTarget(
          semanticLabel: '$label ${text ?? l10n.pjDateNotSet}',
          onTap: () => _pick(context),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AtColors.white,
              borderRadius: AtRadii.input,
              border: Border.all(
                color: errorText == null
                    ? AtColors.inputBorder
                    : AtColors.pinkStrong,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: AtColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text ?? l10n.pjDateNotSet,
                    style: AtTextStyles.body.copyWith(
                      color: text == null ? AtColors.muted : AtColors.ink,
                    ),
                  ),
                ),
                if (clearable && value != null)
                  AtTapTarget(
                    semanticLabel: l10n.pjDateClear,
                    onTap: () => onChanged(null),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: AtColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
          ),
        ],
      ],
    );
  }
}

/// Loading, error and data states for a list or detail screen, so every screen handles all three the same way.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
    this.notFoundTitle,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// Shown instead of the generic failure when the server says 404.
  final String? notFoundTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return value.when(
      loading: () => Semantics(
        label: l10n.loading,
        liveRegion: true,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AtSpacing.gutter),
        child: AtErrorState(
          title: e is ApiFailure && e.statusCode == 404 && notFoundTitle != null
              ? notFoundTitle!
              : l10n.pfLoadFailed,
          body: e is AppFailure ? e.message : const UnexpectedFailure().message,
          ctaLabel: l10n.retry,
          onCta: onRetry,
        ),
      ),
      data: builder,
    );
  }
}

/// "Are you sure?" as a bottom sheet with one destructive action. Resolves to true when confirmed.
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String actionLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final yes = await showAtBottomSheet<bool>(
    context: context,
    title: title,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        4,
        AtSpacing.gutter,
        20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(body, style: AtTextStyles.bodySm.copyWith(color: AtColors.body)),
          const SizedBox(height: 16),
          AtButton(
            label: actionLabel,
            variant: AtButtonVariant.destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: 8),
          AtButton(
            label: l10n.obCropCancel,
            variant: AtButtonVariant.secondary,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
  return yes == true;
}

/// A screen scaffold used by the list screens: top bar with back and an add action, then the body.
class PortfolioScaffold extends StatelessWidget {
  const PortfolioScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.body,
    this.onAdd,
    this.addLabel,
    this.actions = const [],
  });

  final String title;
  final VoidCallback onBack;
  final Widget body;
  final VoidCallback? onAdd;
  final String? addLabel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              title: title,
              onBack: onBack,
              actions: [
                ...actions,
                if (onAdd != null)
                  AtIconButton(
                    icon: LucideIcons.plus,
                    semanticLabel: addLabel ?? title,
                    onPressed: onAdd,
                  ),
              ],
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// A small pill-shaped level bar: four segments, [rank] of them filled.
class LevelBar extends StatelessWidget {
  const LevelBar({super.key, required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 1; i <= 4; i++) ...[
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: i <= rank ? AtColors.primary : AtColors.softTile,
                  borderRadius: AtRadii.pill,
                ),
              ),
            ),
            if (i < 4) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

/// A label with a switch. The whole row is tappable.
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AtRadii.input,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AtTextStyles.body.copyWith(color: AtColors.ink),
                ),
              ),
              ExcludeSemantics(
                child: IgnorePointer(
                  child: AtToggle(
                    value: value,
                    onChanged: onChanged,
                    semanticLabel: label,
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
