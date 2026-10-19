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

SetSkillDtoLevel _levelOf(String json) => SetSkillDtoLevel.values.firstWhere(
  (l) => l.json == json,
  orElse: () => SetSkillDtoLevel.beginner,
);

/// My skills: each with its level, how many published projects use it, and the ways to grow it.
class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  void _soon(BuildContext context, String phase, String name) =>
      context.push(Routes.soonPath(phase, name: name));

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    SkillEntryDto skill,
  ) async {
    final changed = await showAtBottomSheet<bool>(
      context: context,
      title: skill.name,
      builder: (_) => _SkillSheet(existing: skill),
    );
    if (changed == true) _refresh(ref);
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final changed = await showAtBottomSheet<bool>(
      context: context,
      title: AppLocalizations.of(context).skAddTitle,
      builder: (_) => const _SkillSheet(),
    );
    if (changed == true) _refresh(ref);
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(mySkillsProvider);
    ref.invalidate(myProfileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final skills = ref.watch(mySkillsProvider);
    return PortfolioScaffold(
      title: l10n.pfSkills,
      addLabel: l10n.skAddTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.profile),
      onAdd: () => _add(context, ref),
      body: AsyncBody<List<SkillEntryDto>>(
        value: skills,
        onRetry: () => ref.invalidate(mySkillsProvider),
        builder: (list) => list.isEmpty
            ? AtEmptyState(
                icon: LucideIcons.sparkles,
                title: l10n.skEmptyTitle,
                body: l10n.skEmptyBody,
                ctaLabel: l10n.skAddTitle,
                onCta: () => _add(context, ref),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  8,
                  AtSpacing.gutter,
                  AtSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final s = list[i];
                  return AtCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: AtTextStyles.cardTitle.copyWith(
                                  color: AtColors.ink,
                                ),
                              ),
                            ),
                            AtTag(
                              label: switch (s.source) {
                                SkillEntryDtoSource.verified =>
                                  l10n.skSourceVerified,
                                SkillEntryDtoSource.learning =>
                                  l10n.skSourceLearning,
                                _ => l10n.skSourceSelf,
                              },
                              tone: s.source == SkillEntryDtoSource.verified
                                  ? AtTone.success
                                  : AtTone.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          label:
                              '${l10n.skLevelLabel}: ${levelLabel(l10n, s.level?.json)}',
                          child: LevelBar(rank: levelRank(s.level?.json)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${levelLabel(l10n, s.level?.json)} · ${l10n.skUsedIn(s.projectCount.round())}',
                          style: AtTextStyles.meta.copyWith(
                            color: AtColors.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _Action(
                              label: l10n.skImprove,
                              icon: LucideIcons.graduationCap,
                              onTap: () => _soon(context, 'p1', l10n.skImprove),
                            ),
                            _Action(
                              label: l10n.skFindOpportunities,
                              icon: LucideIcons.search,
                              onTap: () => _soon(
                                context,
                                'p1',
                                l10n.skFindOpportunities,
                              ),
                            ),
                            _Action(
                              label: l10n.skVerify,
                              icon: LucideIcons.badgeCheck,
                              onTap: () => _soon(context, 'p2', l10n.skVerify),
                            ),
                            _Action(
                              label: l10n.skChangeLevel,
                              icon: LucideIcons.pencil,
                              onTap: () => _edit(context, ref, s),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AtTapTarget(
    semanticLabel: label,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AtColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AtTextStyles.chip.copyWith(color: AtColors.primary),
          ),
        ],
      ),
    ),
  );
}

/// Add a skill (search the list, pick a level) or change a level or remove one. Resolves to true on change.
class _SkillSheet extends ConsumerStatefulWidget {
  const _SkillSheet({this.existing});

  final SkillEntryDto? existing;

  @override
  ConsumerState<_SkillSheet> createState() => _SkillSheetState();
}

class _SkillSheetState extends ConsumerState<_SkillSheet> {
  final _search = TextEditingController();
  List<TaxonomyItemDto>? _choices;
  Set<String> _owned = {};
  TaxonomyItemDto? _picked;
  late String _level = widget.existing?.level?.json ?? 'INTERMEDIATE';
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existing == null) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(portfolioRepositoryProvider);
      final results = await Future.wait([repo.skillChoices(), repo.mySkills()]);
      if (!mounted) return;
      setState(() {
        _choices = results[0] as List<TaxonomyItemDto>;
        _owned = {for (final s in results[1] as List<SkillEntryDto>) s.id};
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) {
        setState(() => _error = const UnexpectedFailure().message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;
    final picking = existing == null && _picked == null;
    final query = _search.text.trim().toLowerCase();
    final shown = [
      for (final c in _choices ?? const <TaxonomyItemDto>[])
        if (!_owned.contains(c.id) &&
            (query.isEmpty || c.name.toLowerCase().contains(query)))
          c,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        if (picking) ...[
          AtTextField(
            key: const ValueKey('skSearchLabel'),
            label: l10n.skSearchLabel,
            controller: _search,
            prefixIcon: LucideIcons.search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (_choices == null && _error == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.skNoMatches,
                style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in shown.take(60))
                    AtListRow(
                      title: c.name,
                      showChevron: false,
                      onTap: () => setState(() => _picked = c),
                    ),
                ],
              ),
            ),
        ] else ...[
          Text(
            existing?.name ?? _picked!.name,
            style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.skLevelLabel,
            style: AtTextStyles.label.copyWith(color: AtColors.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in skillLevels)
                AtChip(
                  label: levelLabel(l10n, l),
                  selected: _level == l,
                  onTap: () => setState(() => _level = l),
                ),
            ],
          ),
          const SizedBox(height: 20),
          AtButton(
            label: l10n.save,
            loading: _busy,
            onPressed: () => _run(() async {
              final id = existing?.id ?? _picked!.id;
              await ref
                  .read(portfolioRepositoryProvider)
                  .setSkill(id, _levelOf(_level));
              ref.read(analyticsProvider).track('skill_saved');
            }),
          ),
          if (existing != null &&
              existing.source != SkillEntryDtoSource.verified) ...[
            const SizedBox(height: 8),
            AtButton(
              label: l10n.skRemove,
              variant: AtButtonVariant.destructive,
              onPressed: _busy
                  ? null
                  : () async {
                      final ok = await confirmSheet(
                        context,
                        title: l10n.skRemoveTitle(existing.name),
                        body: l10n.skRemoveBody,
                        actionLabel: l10n.skRemove,
                      );
                      if (ok && mounted) {
                        await _run(
                          () => ref
                              .read(portfolioRepositoryProvider)
                              .removeSkill(existing.id),
                        );
                      }
                    },
            ),
          ],
        ],
      ],
    );
  }
}
