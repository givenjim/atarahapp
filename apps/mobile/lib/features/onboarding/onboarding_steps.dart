import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import 'device_services.dart';
import 'onboarding_draft.dart';
import 'onboarding_icons.dart';
import 'onboarding_providers.dart';
import 'onboarding_repository.dart';
import 'pick_sheet.dart';

class StepHeading extends StatelessWidget {
  const StepHeading({super.key, required this.title, this.body, this.bodySpan});

  final String title;
  final String? body;

  /// Use instead of [body] when part of the sentence is emphasised.
  final InlineSpan? bodySpan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AtTextStyles.tabTitle.copyWith(color: AtColors.ink),
          ),
        ),
        const SizedBox(height: 8),
        if (bodySpan != null)
          Text.rich(
            bodySpan!,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
          )
        else if (body != null)
          Text(
            body!,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
          ),
      ],
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = error is AppFailure
        ? (error as AppFailure).message
        : const UnexpectedFailure().message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtInlineBanner(message: message),
        const SizedBox(height: 8),
        AtButton(
          label: l10n.retry,
          variant: AtButtonVariant.secondary,
          size: AtButtonSize.sm,
          fullWidth: false,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
      ),
    ),
  );
}

// ---- 1. intro ------------------------------------------------------------------------------------------------

class IntroStep extends StatelessWidget {
  const IntroStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      (
        LucideIcons.palette,
        AtTone.primary,
        l10n.obIntroDisciplineTitle,
        l10n.obIntroDisciplineBody,
      ),
      (
        LucideIcons.sparkles,
        AtTone.success,
        l10n.obIntroSkillsTitle,
        l10n.obIntroSkillsBody,
      ),
      (
        LucideIcons.mapPin,
        AtTone.pink,
        l10n.obIntroLocationTitle,
        l10n.obIntroLocationBody,
      ),
      (
        LucideIcons.user,
        AtTone.warning,
        l10n.obIntroBasicsTitle,
        l10n.obIntroBasicsBody,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.obIntroTitle,
            style: AtTextStyles.tabTitle.copyWith(
              color: AtColors.ink,
              fontSize: 30,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.obIntroBody,
          style: AtTextStyles.body.copyWith(color: AtColors.body),
        ),
        const SizedBox(height: 22),
        for (final (icon, tone, title, body) in rows) ...[
          AtCard(
            radius: AtRadii.tileLg,
            shadow: false,
            child: Row(
              children: [
                AtIconTile(icon: icon, tone: tone),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AtTextStyles.cardTitle.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: AtTextStyles.meta.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ---- 2. discipline -------------------------------------------------------------------------------------------

class DisciplineStep extends ConsumerWidget {
  const DisciplineStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.watch(disciplinesProvider);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeading(
            title: l10n.obDisciplineTitle,
            body: l10n.obDisciplineBody,
          ),
          const SizedBox(height: 20),
          disciplines.when(
            loading: () => const _TileSkeleton(),
            error: (e, _) => _LoadFailed(
              error: e,
              onRetry: () => ref.invalidate(disciplinesProvider),
            ),
            data: (items) => GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final d in items)
                  _DisciplineTile(
                    discipline: d,
                    selected: draft.disciplineId == d.id,
                    onTap: () => draft.chooseDiscipline(d),
                  ),
              ],
            ),
          ),
          if (draft.fieldErrors['disciplineId'] != null)
            _FieldError(draft.fieldErrors['disciplineId']!),
        ],
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.05,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var i = 0; i < 9; i++) const AtSkeleton(height: 96, radius: 16),
    ],
  );
}

class _DisciplineTile extends StatelessWidget {
  const _DisciplineTile({
    required this.discipline,
    required this.selected,
    required this.onTap,
  });

  final DisciplineDto discipline;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AtColors.white : AtColors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: discipline.name,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: atDuration(context, AtMotion.fast),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AtColors.primary : AtColors.white,
            borderRadius: AtRadii.tileLg,
            border: Border.all(
              color: selected ? AtColors.primary : AtColors.cardBorder,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(91, 69, 240, 0.3),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(lucideByName(discipline.icon), size: 24, color: fg),
              const SizedBox(height: 8),
              Text(
                discipline.name,
                textAlign: TextAlign.center,
                style: AtTextStyles.chipSm.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- 3. specialisation ---------------------------------------------------------------------------------------

class SpecialisationStep extends ConsumerWidget {
  const SpecialisationStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.watch(disciplinesProvider);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final id = draft.disciplineId;
        if (id == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepHeading(title: l10n.obSpecTitle),
              const SizedBox(height: 16),
              AtInlineBanner(
                message: l10n.obSpecNeedDiscipline,
                tone: AtBannerTone.info,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeading(
              title: l10n.obSpecTitle,
              bodySpan: TextSpan(
                children: [
                  TextSpan(text: l10n.obSpecBodyPrefix),
                  TextSpan(
                    text: draft.disciplineName ?? '',
                    style: const TextStyle(
                      color: AtColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: l10n.obSpecBodySuffix),
                ],
              ),
            ),
            const SizedBox(height: 20),
            disciplines.when(
              loading: () => const AtSkeleton(height: 58, radius: 16),
              error: (e, _) => _LoadFailed(
                error: e,
                onRetry: () => ref.invalidate(disciplinesProvider),
              ),
              data: (all) {
                final specs = all
                    .where((d) => d.id == id)
                    .expand((d) => d.specialisations)
                    .toList();
                return Column(
                  children: [
                    for (final s in specs) ...[
                      _SpecRow(
                        label: s.name,
                        selected: draft.specialisationIds.contains(s.id),
                        onTap: () => draft.update(() {
                          if (!draft.specialisationIds.remove(s.id)) {
                            draft.specialisationIds.add(s.id);
                          }
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _SuggestRow(
                      onTap: () => showSuggestSheet(
                        context,
                        disciplineId: id,
                        disciplineName: draft.disciplineName ?? '',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: atDuration(context, AtMotion.fast),
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AtColors.tint3 : AtColors.white,
            borderRadius: AtRadii.tileLg,
            border: Border.all(
              color: selected ? AtColors.primaryLight : AtColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AtTextStyles.bodyLg.copyWith(
                    color: AtColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AtColors.primary : AtColors.white,
                  border: Border.all(
                    color: selected ? AtColors.primary : AtColors.dashedBorder,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: AtColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestRow extends StatelessWidget {
  const _SuggestRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.obSuggest,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CustomPaint(
          painter: const DashedRRectPainter(color: AtColors.dashedBorder),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(LucideIcons.plus, size: 18, color: AtColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.obSuggest,
                    style: AtTextStyles.bodySm.copyWith(
                      color: AtColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded outline for "add" rows.
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) => old.color != color;
}

/// "Suggest a specialization": a small sheet that sends the name to the admin queue.
Future<void> showSuggestSheet(
  BuildContext context, {
  required String disciplineId,
  required String disciplineName,
}) {
  return showAtBottomSheet<void>(
    context: context,
    title: AppLocalizations.of(context).obSuggestTitle,
    builder: (_) => SuggestSheet(
      disciplineId: disciplineId,
      disciplineName: disciplineName,
    ),
  );
}

class SuggestSheet extends ConsumerStatefulWidget {
  const SuggestSheet({
    super.key,
    required this.disciplineId,
    required this.disciplineName,
  });

  final String disciplineId;
  final String disciplineName;

  @override
  ConsumerState<SuggestSheet> createState() => _SuggestSheetState();
}

class _SuggestSheetState extends ConsumerState<SuggestSheet> {
  final _name = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;
  String _sentName = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _error = l10n.obSuggestEmpty);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final receipt = await ref
          .read(onboardingRepositoryProvider)
          .suggestSpecialisation(disciplineId: widget.disciplineId, name: name);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _sentName = receipt.name;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        4,
        AtSpacing.gutter,
        20,
      ),
      child: _sent
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.obSuggestThanksTitle,
                    style: AtTextStyles.sectionTitle.copyWith(
                      color: AtColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.obSuggestThanksBody(_sentName),
                  style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
                ),
                const SizedBox(height: 20),
                AtButton(
                  label: l10n.obSuggestDone,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.obSuggestBody(widget.disciplineName),
                  style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
                ),
                const SizedBox(height: 16),
                AtTextField(
                  label: l10n.obSuggestLabel,
                  controller: _name,
                  maxLength: 60,
                  autofocus: true,
                  errorText: _error,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 16),
                AtButton(
                  label: l10n.obSuggestSend,
                  loading: _busy,
                  onPressed: _busy ? null : _send,
                ),
              ],
            ),
    );
  }
}

// ---- 4. skills, interests, areas -----------------------------------------------------------------------------

class SkillsStep extends ConsumerWidget {
  const SkillsStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final skills = ref.watch(skillOptionsProvider(draft.disciplineId));
        final interests = ref.watch(interestOptionsProvider);
        final areas = ref.watch(developmentAreaOptionsProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeading(title: l10n.obSkillsTitle, body: l10n.obSkillsBody),
            _ChipGroup(
              label: l10n.obGroupSkills,
              options: skills,
              selected: draft.skillIds,
              max: OnboardingLimits.skills,
              onToggle: (id) =>
                  draft.toggle(draft.skillIds, id, OnboardingLimits.skills),
              onRetry: () =>
                  ref.invalidate(skillOptionsProvider(draft.disciplineId)),
            ),
            _ChipGroup(
              label: l10n.obGroupInterests,
              options: interests,
              selected: draft.interestIds,
              max: OnboardingLimits.interests,
              onToggle: (id) => draft.toggle(
                draft.interestIds,
                id,
                OnboardingLimits.interests,
              ),
              onRetry: () => ref.invalidate(interestOptionsProvider),
            ),
            _ChipGroup(
              label: l10n.obGroupGrow,
              options: areas,
              selected: draft.developmentAreaIds,
              max: OnboardingLimits.developmentAreas,
              onToggle: (id) => draft.toggle(
                draft.developmentAreaIds,
                id,
                OnboardingLimits.developmentAreas,
              ),
              onRetry: () => ref.invalidate(developmentAreaOptionsProvider),
            ),
          ],
        );
      },
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.max,
    required this.onToggle,
    required this.onRetry,
  });

  final String label;
  final AsyncValue<List<TaxonomyItemDto>> options;
  final Set<String> selected;
  final int max;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  label,
                  style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.obSelectedCount(selected.length),
                style: AtTextStyles.meta.copyWith(color: AtColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        options.when(
          loading: () => const AtSkeleton(height: 38, radius: 19),
          error: (e, _) => _LoadFailed(error: e, onRetry: onRetry),
          data: (items) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in items)
                AtChip(
                  label: o.name,
                  selected: selected.contains(o.id),
                  icon: selected.contains(o.id)
                      ? LucideIcons.check
                      : LucideIcons.plus,
                  onTap: () => onToggle(o.id),
                ),
            ],
          ),
        ),
        if (selected.length >= max)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.obLimitReached(max),
              style: AtTextStyles.meta.copyWith(color: AtColors.muted),
            ),
          ),
      ],
    );
  }
}

// ---- 5. location ---------------------------------------------------------------------------------------------

class LocationStep extends ConsumerStatefulWidget {
  const LocationStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  late final TextEditingController _town = TextEditingController(
    text: widget.draft.town,
  );
  bool _locating = false;
  String? _locationNote;
  bool _locationNoteIsError = false;

  OnboardingDraft get draft => widget.draft;

  @override
  void dispose() {
    _town.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _locating = true;
      _locationNote = null;
    });
    final lookup = ref.read(locationLookupProvider);
    final repo = ref.read(onboardingRepositoryProvider);
    String? note;
    var isError = true;
    try {
      final names = await lookup.placeNames();
      CountyDto? found;
      String? countryId;
      for (final name in names) {
        final match = await repo.matchCounty(name, country: draft.countryId);
        countryId = match.countryId ?? countryId;
        if (match.county != null) {
          found = match.county;
          break;
        }
      }
      if (found == null) {
        note = l10n.obLocationNoMatch;
      } else {
        draft.update(() {
          draft.countyId = found!.id;
          draft.countyName = found.name;
          draft.countryId = countryId ?? draft.countryId;
          draft.fieldErrors.remove('countyId');
        });
        note = l10n.obLocationFound(found.name);
        isError = false;
      }
    } on LocationLookupException catch (e) {
      note = switch (e.problem) {
        LocationProblem.permissionDenied => l10n.obLocationDenied,
        LocationProblem.permissionDeniedForever => l10n.obLocationDeniedForever,
        LocationProblem.servicesOff => l10n.obLocationServicesOff,
        LocationProblem.unavailable => l10n.obLocationFailed,
      };
    } on AppFailure catch (e) {
      note = e.message;
    }
    if (!mounted) return;
    setState(() {
      _locating = false;
      _locationNote = note;
      _locationNoteIsError = isError;
    });
  }

  Future<void> _chooseCountry(List<CountryDto> countries) async {
    final l10n = AppLocalizations.of(context);
    final id = await showPickSheet(
      context,
      title: l10n.obChooseCountry,
      options: [for (final c in countries) PickOption(c.id, c.name)],
      selectedId: draft.countryId,
    );
    if (id == null || id == draft.countryId) return;
    draft.update(() {
      draft.countryId = id;
      draft.countyId = null;
      draft.countyName = null;
    });
  }

  Future<void> _chooseCounty(List<CountyDto> counties) async {
    final l10n = AppLocalizations.of(context);
    final id = await showPickSheet(
      context,
      title: l10n.obChooseCounty,
      options: [for (final c in counties) PickOption(c.id, c.name)],
      selectedId: draft.countyId,
      searchable: true,
    );
    if (id == null) return;
    final county = counties.firstWhere((c) => c.id == id);
    draft.update(() {
      draft.countyId = id;
      draft.countyName = county.name;
      draft.fieldErrors.remove('countyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countries = ref.watch(countryOptionsProvider);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        // The only country today is Kenya; it is chosen for the member until there is more than one.
        final countryList = countries.value ?? const <CountryDto>[];
        if (draft.countryId == null && countryList.length == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (draft.countryId == null) {
              draft.update(() => draft.countryId = countryList.first.id);
            }
          });
        }
        final counties = ref.watch(countyOptionsProvider(draft.countryId));
        final countryName = countryList
            .where((c) => c.id == draft.countryId)
            .map((c) => c.name)
            .firstOrNull;
        final visIndex = switch (draft.visibility) {
          SaveOnboardingStepDtoLocationVisibility.public => 0,
          SaveOnboardingStepDtoLocationVisibility.members => 1,
          _ => 2,
        };
        final note = switch (visIndex) {
          0 => l10n.obVisPublicNote,
          1 => l10n.obVisMembersNote,
          _ => l10n.obVisPrivateNote,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeading(title: l10n.obLocTitle, body: l10n.obLocBody),
            const SizedBox(height: 20),
            if (countries.hasError)
              _LoadFailed(
                error: countries.error!,
                onRetry: () => ref.invalidate(countryOptionsProvider),
              ),
            PickerField(
              label: l10n.obCountry,
              value: countryName,
              placeholder: l10n.obSelectPlaceholder,
              onTap: countryList.isEmpty
                  ? null
                  : () => _chooseCountry(countryList),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.obCounty,
              value: draft.countyName,
              placeholder: l10n.obSelectPlaceholder,
              errorText: draft.fieldErrors['countyId'],
              onTap: counties.hasValue
                  ? () => _chooseCounty(counties.requireValue)
                  : null,
            ),
            if (counties.hasError)
              _LoadFailed(
                error: counties.error!,
                onRetry: () =>
                    ref.invalidate(countyOptionsProvider(draft.countryId)),
              ),
            const SizedBox(height: 14),
            AtTextField(
              label: l10n.obTown,
              controller: _town,
              maxLength: 80,
              textInputAction: TextInputAction.done,
              onChanged: (v) => draft.town = v,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: AtButton(
                label: _locating ? l10n.obLocating : l10n.obUseLocation,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.sm,
                fullWidth: false,
                icon: LucideIcons.locateFixed,
                onPressed: _locating ? null : _useCurrentLocation,
              ),
            ),
            if (_locationNote != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AtInlineBanner(
                  message: _locationNote!,
                  tone: _locationNoteIsError
                      ? AtBannerTone.info
                      : AtBannerTone.success,
                ),
              ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AtColors.tint3,
                borderRadius: AtRadii.cardLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.obWhoSees,
                    style: AtTextStyles.bodySm.copyWith(
                      color: AtColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AtSegmented(
                    labels: [
                      l10n.obVisPublic,
                      l10n.obVisMembers,
                      l10n.obVisPrivate,
                    ],
                    selectedIndex: visIndex,
                    onChanged: (i) => draft.update(
                      () => draft.visibility = switch (i) {
                        0 => SaveOnboardingStepDtoLocationVisibility.public,
                        1 => SaveOnboardingStepDtoLocationVisibility.members,
                        _ => SaveOnboardingStepDtoLocationVisibility.private,
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    note,
                    style: AtTextStyles.meta.copyWith(color: AtColors.body),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---- 6. basics -----------------------------------------------------------------------------------------------

class BasicsStep extends ConsumerStatefulWidget {
  const BasicsStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  ConsumerState<BasicsStep> createState() => _BasicsStepState();
}

class _BasicsStepState extends ConsumerState<BasicsStep> {
  late final TextEditingController _name = TextEditingController(
    text: widget.draft.displayName,
  );
  late final TextEditingController _handle = TextEditingController(
    text: widget.draft.handle,
  );
  late final TextEditingController _bio = TextEditingController(
    text: widget.draft.bio,
  );
  Timer? _debounce;
  int _checkSeq = 0;

  OnboardingDraft get draft => widget.draft;

  @override
  void initState() {
    super.initState();
    // A handle the member already saved is theirs, so it needs no check. Otherwise suggest one from the name.
    if (draft.handle.isEmpty) {
      final suggested = suggestHandle(draft.displayName);
      if (suggested != null) {
        _handle.text = suggested;
        draft.handle = suggested;
        _scheduleCheck(immediate: true);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _handle.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _onHandleChanged(String raw) {
    final value = raw.trim().toLowerCase();
    draft.handle = value;
    draft.fieldErrors.remove('handle');
    if (value.isEmpty) {
      _debounce?.cancel();
      draft.update(() => draft.handleStatus = const HandleUnknown());
      return;
    }
    if (!handlePattern.hasMatch(value)) {
      _debounce?.cancel();
      draft.update(
        () => draft.handleStatus = const HandleUnavailable(
          HandleAvailabilityDtoReason.invalid,
          [],
        ),
      );
      return;
    }
    draft.update(() => draft.handleStatus = const HandleChecking());
    _scheduleCheck();
  }

  void _scheduleCheck({bool immediate = false}) {
    _debounce?.cancel();
    final value = draft.handle;
    final seq = ++_checkSeq;
    _debounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 400),
      () async {
        try {
          final res = await ref
              .read(onboardingRepositoryProvider)
              .handleAvailability(value);
          // A newer keystroke supersedes this answer.
          if (!mounted || seq != _checkSeq || draft.handle != value) return;
          draft.update(
            () => draft.handleStatus = res.available
                ? const HandleAvailable()
                : HandleUnavailable(
                    res.reason ?? HandleAvailabilityDtoReason.taken,
                    res.suggestions,
                  ),
          );
        } on AppFailure {
          // Offline or rate limited: the save itself still validates, so do not block typing.
          if (mounted && seq == _checkSeq) {
            draft.update(() => draft.handleStatus = const HandleUnknown());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final status = draft.handleStatus;
        final String? handleError =
            draft.fieldErrors['handle'] ??
            switch (status) {
              HandleUnavailable(:final reason) => switch (reason) {
                HandleAvailabilityDtoReason.reserved => l10n.obHandleReserved,
                HandleAvailabilityDtoReason.invalid => l10n.obHandleInvalid,
                _ => l10n.obHandleTaken,
              },
              _ => null,
            };
        final suggestions = switch (status) {
          HandleUnavailable(:final suggestions) => suggestions,
          _ => const <String>[],
        };
        final helper = switch (status) {
          HandleChecking() => l10n.obHandleChecking,
          HandleAvailable() when draft.handle.isNotEmpty =>
            l10n.obHandleAvailable(draft.handle),
          _ => null,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeading(title: l10n.obBasicsTitle, body: l10n.obBasicsBody),
            const SizedBox(height: 20),
            AtTextField(
              label: l10n.obDisplayName,
              controller: _name,
              maxLength: 60,
              errorText: draft.fieldErrors['displayName'],
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              onChanged: (v) {
                draft.displayName = v;
                if (draft.fieldErrors.remove('displayName') != null) {
                  draft.update(() {});
                }
              },
            ),
            const SizedBox(height: 14),
            AtTextField(
              label: l10n.obProfileLink,
              controller: _handle,
              prefixText: 'atarah.app/',
              maxLength: OnboardingLimits.handleMax,
              errorText: handleError,
              helperText: helper,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.visiblePassword,
              onChanged: _onHandleChanged,
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Semantics(
                container: true,
                label: l10n.obHandleSuggestionsLabel,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions)
                      AtChip(
                        label: s,
                        onTap: () {
                          _handle.text = s;
                          _onHandleChanged(s);
                        },
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            AtTextField(
              label: l10n.obShortBio,
              controller: _bio,
              minLines: 4,
              maxLines: 6,
              maxLength: OnboardingLimits.bio,
              showCounter: true,
              errorText: draft.fieldErrors['bio'],
              onChanged: (v) {
                draft.bio = v;
                if (draft.fieldErrors.remove('bio') != null) {
                  draft.update(() {});
                }
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: AtButton(
                label: l10n.obHelpWrite,
                variant: AtButtonVariant.secondary,
                size: AtButtonSize.sm,
                fullWidth: false,
                icon: LucideIcons.sparkles,
                // The writing assistant is a Phase 3 feature.
                onPressed: () =>
                    context.push(Routes.soonPath('p3', name: l10n.obHelpWrite)),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A starting point for the profile link from the display name: "Nia Wairimu" gives "niawairimu".
/// Null when the name has too few letters to make a valid link.
String? suggestHandle(String name) {
  final base = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .padRight(0);
  if (base.length < OnboardingLimits.handleMin) return null;
  final trimmed = base.length > 24 ? base.substring(0, 24) : base;
  return handlePattern.hasMatch(trimmed) ? trimmed : null;
}

// ---- 7. photo ------------------------------------------------------------------------------------------------

class PhotoStep extends ConsumerStatefulWidget {
  const PhotoStep({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  ConsumerState<PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends ConsumerState<PhotoStep> {
  String? _error;

  OnboardingDraft get draft => widget.draft;

  Future<void> _pick({required bool camera}) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    try {
      final bytes = await ref.read(photoPickerProvider).pick(camera: camera);
      if (bytes == null || !mounted) return;
      final cropped = await ref.read(photoCropperProvider)(context, bytes);
      if (cropped == null || !mounted) return;
      draft.update(() => draft.uploadingPhoto = true);
      try {
        final state = await ref
            .read(onboardingControllerProvider.notifier)
            .uploadAvatar(
              AvatarUpload(bytes: cropped.bytes, mimeType: cropped.mimeType),
            );
        draft.update(() => draft.avatarUrl = state.profile.avatarUrl);
      } on AppFailure catch (e) {
        if (mounted) setState(() => _error = e.message);
      } finally {
        draft.update(() => draft.uploadingPhoto = false);
      }
    } on Object {
      // The picker or camera permission failed in a way we cannot say more about.
      if (mounted) setState(() => _error = l10n.obPhotoPickFailed);
    }
  }

  Future<void> _remove() async {
    setState(() => _error = null);
    draft.update(() => draft.uploadingPhoto = true);
    try {
      final next = await ref.read(onboardingRepositoryProvider).removeAvatar();
      ref.read(onboardingControllerProvider.notifier).apply(next);
      draft.update(() => draft.avatarUrl = null);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      draft.update(() => draft.uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final url = draft.avatarUrl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeading(title: l10n.obPhotoTitle, body: l10n.obPhotoBody),
            const SizedBox(height: 24),
            Center(
              child: Semantics(
                image: true,
                label: l10n.obPhotoPreview,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AtColors.white, spreadRadius: 6),
                            BoxShadow(
                              color: AtColors.dashedBorder,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: AtAvatar(
                          name: draft.displayName,
                          size: 200,
                          image: url == null
                              ? null
                              : ref.watch(avatarImageProvider)(url),
                        ),
                      ),
                      if (draft.uploadingPhoto)
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(255, 255, 255, 0.6),
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AtGradients.cta,
                            boxShadow: [
                              BoxShadow(color: AtColors.white, spreadRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 20,
                            color: AtColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AtButton(
                    label: l10n.obGallery,
                    variant: AtButtonVariant.secondary,
                    icon: LucideIcons.image,
                    onPressed: draft.uploadingPhoto
                        ? null
                        : () => _pick(camera: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AtButton(
                    label: l10n.obTakePhoto,
                    variant: AtButtonVariant.secondary,
                    icon: LucideIcons.camera,
                    onPressed: draft.uploadingPhoto
                        ? null
                        : () => _pick(camera: true),
                  ),
                ),
              ],
            ),
            if (draft.uploadingPhoto) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.obPhotoUploading,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ),
            ] else if (url != null) ...[
              const SizedBox(height: 12),
              AtInlineBanner(
                message: l10n.obPhotoAdded,
                tone: AtBannerTone.success,
                action: AtButton(
                  label: l10n.obPhotoRemove,
                  variant: AtButtonVariant.tertiary,
                  size: AtButtonSize.sm,
                  fullWidth: false,
                  onPressed: _remove,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              AtInlineBanner(message: _error!),
            ],
          ],
        );
      },
    );
  }
}
