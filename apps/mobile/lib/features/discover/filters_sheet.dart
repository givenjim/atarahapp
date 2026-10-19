import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../onboarding/onboarding_icons.dart';
import '../onboarding/onboarding_providers.dart';
import 'discover_providers.dart';
import 'discover_repository.dart';

/// Opens the filters for Explore. Changes apply when "Show n results" is pressed; Reset clears every group.
Future<void> showFiltersSheet(BuildContext context) => showAtBottomSheet<void>(
  context: context,
  title: AppLocalizations.of(context).dcFilters,
  builder: (_) => const FiltersSheet(),
);

class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key});

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late CreativeFilters _draft = ref.read(exploreFiltersProvider);

  void _set(CreativeFilters next) => setState(() => _draft = next);

  Future<void> _chooseCounty(List<CountyDto> counties) async {
    final picked = await showAtBottomSheet<CountyDto?>(
      context: context,
      title: AppLocalizations.of(context).dcCounty,
      builder: (ctx) =>
          _CountyList(counties: counties, selected: _draft.countyId),
    );
    if (picked == null || !mounted) return;
    _set(_draft.copyWith(countyId: picked.id, countyName: picked.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.watch(disciplinesProvider).value ?? const [];
    final counties = ref.watch(countyOptionsProvider(null)).value ?? const [];
    final count = ref.watch(creativeCountProvider(_draft));
    final total = count.value;

    Widget group(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
          ),
        ),
        const SizedBox(height: 10),
        child,
        const SizedBox(height: AtSpacing.sectionGap),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        0,
        AtSpacing.gutter,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AtButton(
              label: l10n.dcReset,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: _draft.isEmpty
                  ? null
                  : () => _set(const CreativeFilters()),
            ),
          ),
          group(
            l10n.dcDiscipline,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AtChip(
                  label: l10n.dcAll,
                  selected: _draft.disciplineId == null,
                  onTap: () => _set(_draft.copyWith(disciplineId: null)),
                ),
                for (final d in disciplines)
                  AtChip(
                    label: d.name,
                    icon: lucideByName(d.icon),
                    selected: _draft.disciplineId == d.id,
                    onTap: () => _set(_draft.copyWith(disciplineId: d.id)),
                  ),
              ],
            ),
          ),
          group(
            l10n.dcLocation,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AtChip(
                  label: l10n.dcAnywhere,
                  selected: _draft.countyId == null,
                  onTap: () =>
                      _set(_draft.copyWith(countyId: null, countyName: null)),
                ),
                if (_draft.countyId != null)
                  AtChip(label: _draft.countyName ?? '', selected: true),
                AtChip(
                  label: l10n.dcChooseCounty,
                  icon: LucideIcons.mapPin,
                  onTap: counties.isEmpty
                      ? null
                      : () => _chooseCounty(counties),
                ),
              ],
            ),
          ),
          group(
            l10n.dcAvailability,
            _ToggleRow(
              title: l10n.dcOpenToCommissions,
              value: _draft.available,
              onChanged: (v) => _set(_draft.copyWith(available: v)),
            ),
          ),
          _ToggleRow(
            title: l10n.dcVerifiedOnly,
            body: l10n.dcVerifiedOnlyBody,
            value: _draft.verified,
            onChanged: (v) => _set(_draft.copyWith(verified: v)),
          ),
          const SizedBox(height: AtSpacing.sectionGap),
          group(
            l10n.dcSortBy,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AtChip(
                  label: l10n.dcSortRelevance,
                  selected: !_draft.recent,
                  onTap: () => _set(_draft.copyWith(recent: false)),
                ),
                AtChip(
                  label: l10n.dcSortRecent,
                  selected: _draft.recent,
                  onTap: () => _set(_draft.copyWith(recent: true)),
                ),
              ],
            ),
          ),
          AtButton(
            label: total == null
                ? l10n.dcShowResultsLoading
                : l10n.dcShowResults(total),
            onPressed: () {
              ref.read(exploreFiltersProvider.notifier).set(_draft);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.body,
  });

  final String title;
  final String? body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    behavior: HitTestBehavior.opaque,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AtTextStyles.body.copyWith(color: AtColors.ink),
              ),
              if (body != null)
                Text(
                  body!,
                  style: AtTextStyles.metaSm.copyWith(color: AtColors.muted),
                ),
            ],
          ),
        ),
        AtToggle(value: value, onChanged: onChanged, semanticLabel: title),
      ],
    ),
  );
}

class _CountyList extends StatelessWidget {
  const _CountyList({required this.counties, required this.selected});

  final List<CountyDto> counties;
  final String? selected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.6,
    child: ListView(
      children: [
        for (final c in counties)
          AtListRow(
            title: c.name,
            showChevron: false,
            trailing: c.id == selected
                ? const Icon(LucideIcons.check, color: AtColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(c),
          ),
      ],
    ),
  );
}
