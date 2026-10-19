import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../profile/profile_providers.dart';
import 'portfolio_common.dart';
import 'portfolio_providers.dart';

/// "Mar 2022 – Present" or "Mar 2022 – Jun 2024".
String experienceRange(BuildContext context, ExperienceDto e) {
  final l10n = AppLocalizations.of(context);
  final end = e.current ? l10n.xpPresent : monthYear(context, e.endDate);
  return '${monthYear(context, e.startDate)} – $end';
}

/// My experience, newest first, with the current role on top.
class ExperienceScreen extends ConsumerWidget {
  const ExperienceScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    ExperienceDto? existing,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final changed = await showAtBottomSheet<bool>(
      context: context,
      title: existing == null ? l10n.xpAddTitle : l10n.xpEditTitle,
      builder: (_) => _ExperienceSheet(existing: existing),
    );
    if (changed == true) {
      ref.invalidate(myExperienceProvider);
      ref.invalidate(myProfileProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(myExperienceProvider);
    return PortfolioScaffold(
      title: l10n.pfExperience,
      addLabel: l10n.xpAddTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.profile),
      onAdd: () => _edit(context, ref),
      body: AsyncBody<List<ExperienceDto>>(
        value: items,
        onRetry: () => ref.invalidate(myExperienceProvider),
        builder: (list) => list.isEmpty
            ? AtEmptyState(
                icon: LucideIcons.briefcase,
                title: l10n.xpEmptyTitle,
                body: l10n.xpEmptyBody,
                tone: AtTone.warning,
                ctaLabel: l10n.xpAddTitle,
                onCta: () => _edit(context, ref),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  8,
                  AtSpacing.gutter,
                  AtSpacing.xl,
                ),
                children: [
                  AtCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final (i, e) in list.indexed)
                          AtListRow(
                            title: e.title,
                            subtitle:
                                '${e.organisation} · ${experienceRange(context, e)}',
                            icon: LucideIcons.briefcase,
                            tone: AtTone.warning,
                            showDivider: i < list.length - 1,
                            onTap: () => _edit(context, ref, e),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ExperienceSheet extends ConsumerStatefulWidget {
  const _ExperienceSheet({this.existing});

  final ExperienceDto? existing;

  @override
  ConsumerState<_ExperienceSheet> createState() => _ExperienceSheetState();
}

class _ExperienceSheetState extends ConsumerState<_ExperienceSheet> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _org = TextEditingController(text: widget.existing?.organisation);
  late final _location = TextEditingController(text: widget.existing?.location);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late String? _start = widget.existing?.startDate;
  late String? _end = widget.existing?.endDate;
  late bool _current = widget.existing?.current ?? false;

  bool _busy = false;
  String? _titleError;
  String? _orgError;
  String? _startError;
  String? _endError;
  String? _banner;

  @override
  void dispose() {
    _title.dispose();
    _org.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  bool _check(AppLocalizations l10n) {
    _titleError = _title.text.trim().length < 2 ? l10n.xpTitleError : null;
    _orgError = _org.text.trim().length < 2 ? l10n.xpOrgError : null;
    _startError = _start == null ? l10n.xpStartError : null;
    _endError = null;
    if (!_current) {
      if (_end == null) {
        _endError = l10n.xpEndRequired;
      } else if (_start != null && _end!.compareTo(_start!) < 0) {
        _endError = l10n.xpEndBeforeStart;
      }
    }
    return _titleError == null &&
        _orgError == null &&
        _startError == null &&
        _endError == null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _busy = _check(l10n);
    });
    if (!_busy) return;
    final repo = ref.read(portfolioRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing == null) {
        await repo.addExperience(
          ExperienceInputDto(
            title: _title.text.trim(),
            organisation: _org.text.trim(),
            location: _location.text.trim().isEmpty
                ? null
                : _location.text.trim(),
            startDate: _start!,
            endDate: _current ? null : _end,
            current: _current,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
          ),
        );
      } else {
        await repo.updateExperience(
          existing.id,
          UpdateExperienceDto(
            title: _title.text.trim(),
            organisation: _org.text.trim(),
            location: _location.text.trim(),
            startDate: _start,
            endDate: _current ? '' : _end ?? '',
            current: _current,
            description: _description.text.trim(),
          ),
        );
      }
      ref.read(analyticsProvider).track('experience_saved');
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _titleError = e.fieldError('title');
        _orgError = e.fieldError('organisation');
        _startError = e.fieldError('startDate');
        _endError = e.fieldError('endDate');
        _banner = (_titleError ?? _orgError ?? _startError ?? _endError) == null
            ? e.message
            : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing!;
    final ok = await confirmSheet(
      context,
      title: l10n.xpDeleteTitle,
      body: l10n.xpDeleteBody,
      actionLabel: l10n.xpDelete,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(portfolioRepositoryProvider).deleteExperience(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_banner != null) ...[
          AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(
          key: const ValueKey('xpTitleLabel'),
          label: l10n.xpTitleLabel,
          controller: _title,
          maxLength: 80,
          errorText: _titleError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('xpOrgLabel'),
          label: l10n.xpOrgLabel,
          hint: l10n.xpOrgHint,
          controller: _org,
          maxLength: 80,
          errorText: _orgError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('xpLocationLabel'),
          label: l10n.xpLocationLabel,
          controller: _location,
          maxLength: 80,
        ),
        const SizedBox(height: 12),
        DateField(
          key: const ValueKey('xpStartLabel'),
          label: l10n.xpStartLabel,
          value: _start,
          clearable: false,
          errorText: _startError,
          onChanged: (v) => setState(() => _start = v),
        ),
        const SizedBox(height: 12),
        ToggleRow(
          label: l10n.xpCurrentLabel,
          value: _current,
          onChanged: (v) => setState(() => _current = v),
        ),
        if (!_current) ...[
          const SizedBox(height: 12),
          DateField(
            key: const ValueKey('xpEndLabel'),
            label: l10n.xpEndLabel,
            value: _end,
            clearable: false,
            errorText: _endError,
            onChanged: (v) => setState(() => _end = v),
          ),
        ],
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('xpDescriptionLabel'),
          label: l10n.xpDescriptionLabel,
          controller: _description,
          minLines: 3,
          maxLines: 5,
          maxLength: 1000,
        ),
        const SizedBox(height: 20),
        AtButton(label: l10n.save, loading: _busy, onPressed: _save),
        if (widget.existing != null) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.xpDelete,
            variant: AtButtonVariant.destructive,
            onPressed: _busy ? null : _delete,
          ),
        ],
      ],
    );
  }
}
