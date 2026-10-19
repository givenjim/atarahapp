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

final _https = RegExp(r'^https://[^\s/]+\.[^\s/]+', caseSensitive: false);

/// My achievements: awards, certificates, features, selections and nominations.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AchievementDto? existing,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final changed = await showAtBottomSheet<bool>(
      context: context,
      title: existing == null ? l10n.acAddTitle : l10n.acEditTitle,
      builder: (_) => _AchievementSheet(existing: existing),
    );
    if (changed == true) {
      ref.invalidate(myAchievementsProvider);
      ref.invalidate(myProfileProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(myAchievementsProvider);
    return PortfolioScaffold(
      title: l10n.pfAchievements,
      addLabel: l10n.acAddTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.profile),
      onAdd: () => _edit(context, ref),
      body: AsyncBody<List<AchievementDto>>(
        value: items,
        onRetry: () => ref.invalidate(myAchievementsProvider),
        builder: (list) => list.isEmpty
            ? AtEmptyState(
                icon: LucideIcons.award,
                title: l10n.acEmptyTitle,
                body: l10n.acEmptyBody,
                tone: AtTone.amber,
                ctaLabel: l10n.acAddTitle,
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
                        for (final (i, a) in list.indexed)
                          AtListRow(
                            title: a.title,
                            subtitle: [
                              achievementTypeLabel(l10n, a.type.json),
                              if (a.issuer != null) a.issuer!,
                              if (a.achievedOn != null)
                                monthYear(context, a.achievedOn),
                            ].join(' · '),
                            icon: achievementIcon(a.type.json),
                            tone: AtTone.amber,
                            trailing: a.source == AchievementDtoSource.system
                                ? AtTag(
                                    label: l10n.acByAtarah,
                                    tone: AtTone.primary,
                                  )
                                : null,
                            showChevron:
                                a.source != AchievementDtoSource.system,
                            showDivider: i < list.length - 1,
                            // Achievements Atarah added (certificates from Skill Labs) cannot be edited.
                            onTap: a.source == AchievementDtoSource.system
                                ? null
                                : () => _edit(context, ref, a),
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

class _AchievementSheet extends ConsumerStatefulWidget {
  const _AchievementSheet({this.existing});

  final AchievementDto? existing;

  @override
  ConsumerState<_AchievementSheet> createState() => _AchievementSheetState();
}

class _AchievementSheetState extends ConsumerState<_AchievementSheet> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _issuer = TextEditingController(text: widget.existing?.issuer);
  late final _url = TextEditingController(text: widget.existing?.url);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late String _type = widget.existing?.type.json ?? 'AWARD';
  late String? _date = widget.existing?.achievedOn;

  bool _busy = false;
  String? _titleError;
  String? _urlError;
  String? _banner;

  @override
  void dispose() {
    _title.dispose();
    _issuer.dispose();
    _url.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    _titleError = _title.text.trim().length < 2 ? l10n.acTitleError : null;
    _urlError =
        _url.text.trim().isNotEmpty && !_https.hasMatch(_url.text.trim())
        ? l10n.acUrlError
        : null;
    _banner = null;
    if (_titleError != null || _urlError != null) {
      setState(() {});
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(portfolioRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing == null) {
        await repo.addAchievement(
          AchievementInputDto(
            type: AchievementInputDtoType.values.firstWhere(
              (t) => t.json == _type,
              orElse: () => AchievementInputDtoType.award,
            ),
            title: _title.text.trim(),
            issuer: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
            achievedOn: _date,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            url: _url.text.trim().isEmpty ? null : _url.text.trim(),
          ),
        );
      } else {
        await repo.updateAchievement(
          existing.id,
          UpdateAchievementDto(
            type: UpdateAchievementDtoType.values.firstWhere(
              (t) => t.json == _type,
              orElse: () => UpdateAchievementDtoType.award,
            ),
            title: _title.text.trim(),
            issuer: _issuer.text.trim(),
            achievedOn: _date ?? '',
            description: _description.text.trim(),
            url: _url.text.trim(),
          ),
        );
      }
      ref.read(analyticsProvider).track('achievement_saved');
      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _titleError = e.fieldError('title');
        _urlError = e.fieldError('url');
        _banner = (_titleError ?? _urlError) == null ? e.message : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l10n.acDeleteTitle,
      body: l10n.acDeleteBody,
      actionLabel: l10n.acDelete,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(portfolioRepositoryProvider)
          .deleteAchievement(widget.existing!.id);
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
        Text(
          l10n.acTypeLabel,
          style: AtTextStyles.label.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in achievementTypes)
              AtChip(
                label: achievementTypeLabel(l10n, t),
                selected: _type == t,
                onTap: () => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('acTitleLabel'),
          label: l10n.acTitleLabel,
          controller: _title,
          maxLength: 100,
          errorText: _titleError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('acIssuerLabel'),
          label: l10n.acIssuerLabel,
          controller: _issuer,
          maxLength: 80,
        ),
        const SizedBox(height: 12),
        DateField(
          key: const ValueKey('acDateLabel'),
          label: l10n.acDateLabel,
          value: _date,
          onChanged: (v) => setState(() => _date = v),
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('acUrlLabel'),
          label: l10n.acUrlLabel,
          hint: 'https://',
          controller: _url,
          keyboardType: TextInputType.url,
          maxLength: 300,
          errorText: _urlError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('acDescriptionLabel'),
          label: l10n.acDescriptionLabel,
          controller: _description,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
        ),
        const SizedBox(height: 20),
        AtButton(label: l10n.save, loading: _busy, onPressed: _save),
        if (widget.existing != null) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.acDelete,
            variant: AtButtonVariant.destructive,
            onPressed: _busy ? null : _delete,
          ),
        ],
      ],
    );
  }
}
