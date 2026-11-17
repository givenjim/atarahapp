import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../onboarding/onboarding_icons.dart';
import '../onboarding/onboarding_providers.dart';
import 'opportunities_common.dart';
import 'opportunities_repository.dart';

/// Opens the filters for an opportunities list and answers the filters the member chose (null if dismissed).
/// Discipline, county, remote, how soon it closes and the trust level; the category and the sort stay as they were.
Future<OpportunityFilters?> showOpportunityFiltersSheet(
  BuildContext context,
  OpportunityFilters current,
) => showAtBottomSheet<OpportunityFilters>(
  context: context,
  title: AppLocalizations.of(context).dcFilters,
  builder: (_) => OpportunityFiltersSheet(current: current),
);

class OpportunityFiltersSheet extends ConsumerStatefulWidget {
  const OpportunityFiltersSheet({super.key, required this.current});

  final OpportunityFilters current;

  @override
  ConsumerState<OpportunityFiltersSheet> createState() =>
      _OpportunityFiltersSheetState();
}

class _OpportunityFiltersSheetState
    extends ConsumerState<OpportunityFiltersSheet> {
  late OpportunityFilters _draft = widget.current;

  void _set(OpportunityFilters next) => setState(() => _draft = next);

  Future<void> _chooseCounty(List<CountyDto> counties) async {
    final picked = await showAtBottomSheet<CountyDto?>(
      context: context,
      title: AppLocalizations.of(context).dcCounty,
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.6,
        child: ListView(
          children: [
            for (final c in counties)
              AtListRow(
                title: c.name,
                showChevron: false,
                trailing: c.id == _draft.countyId
                    ? Icon(LucideIcons.check, color: ctx.at.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(c),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    _set(_draft.copyWith(countyId: picked.id, countyName: picked.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.watch(disciplinesProvider).value ?? const [];
    final counties = ref.watch(countyOptionsProvider(null)).value ?? const [];

    Widget group(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
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
              onPressed: _draft.activeCount == 0
                  ? null
                  : () => _set(_draft.cleared()),
            ),
          ),
          group(
            l10n.opFilterDeadline,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AtChip(
                  label: l10n.opFilterAnyTime,
                  selected: _draft.deadline == null,
                  onTap: () => _set(_draft.copyWith(deadline: null)),
                ),
                for (final (d, days) in [
                  (Deadline.value7d, 7),
                  (Deadline.value14d, 14),
                  (Deadline.value30d, 30),
                ])
                  AtChip(
                    label: l10n.opFilterDays(days),
                    selected: _draft.deadline == d,
                    onTap: () => _set(_draft.copyWith(deadline: d)),
                  ),
              ],
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _set(_draft.copyWith(remote: !_draft.remote)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.opFilterRemote,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                      Text(
                        l10n.opFilterRemoteBody,
                        style: AtTextStyles.metaSm.copyWith(
                          color: context.at.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                AtToggle(
                  value: _draft.remote,
                  onChanged: (v) => _set(_draft.copyWith(remote: v)),
                  semanticLabel: l10n.opFilterRemote,
                ),
              ],
            ),
          ),
          const SizedBox(height: AtSpacing.sectionGap),
          group(
            l10n.opFilterTrust,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AtChip(
                  label: l10n.opFilterTrustAny,
                  selected: _draft.trust == null,
                  onTap: () => _set(_draft.copyWith(trust: null)),
                ),
                for (final t in [
                  OpportunityTrust.verified,
                  OpportunityTrust.sourceConfirmed,
                  OpportunityTrust.externalSource,
                ])
                  AtChip(
                    label: trustLabel(l10n, t),
                    icon: trustIcon(t),
                    selected: _draft.trust == t,
                    onTap: () => _set(_draft.copyWith(trust: t)),
                  ),
              ],
            ),
          ),
          AtButton(
            label: l10n.opFilterApply,
            onPressed: () => Navigator.of(context).pop(_draft),
          ),
        ],
      ),
    );
  }
}
