import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../discover/discover_common.dart';
import '../onboarding/onboarding_providers.dart';
import 'mentorship_common.dart';
import 'mentorship_repository.dart';

/// The "price under" chip and sheet option: KES 2,000 in minor units. A fixed, documented threshold of the filter
/// control (not listing data).
const mentorPriceCapMinor = 200000;

/// The mentor directory: search, filter chips (Verified, discipline, Available this week, price under X, Video
/// call), a filters button for the sheet, and mentor cards with next availability, rating and "From KES x".
class MentorsListScreen extends ConsumerStatefulWidget {
  const MentorsListScreen({super.key});

  @override
  ConsumerState<MentorsListScreen> createState() => _MentorsListScreenState();
}

class _MentorsListScreenState extends ConsumerState<MentorsListScreen> {
  MentorFilters _filters = const MentorFilters();
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _set(MentorFilters next) => setState(() => _filters = next);

  Future<void> _openSheet() async {
    final next = await showAtBottomSheet<MentorFilters>(
      context: context,
      title: AppLocalizations.of(context).dcFilters,
      builder: (_) => _MentorFiltersSheet(current: _filters),
    );
    if (next != null && mounted) _set(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(mentorDirectoryProvider(_filters));
    final cap = formatMoney(mentorPriceCapMinor, 'KES');
    return MentorshipScaffold(
      title: l10n.mnDirectoryTitle,
      actions: [
        AtIconButton(
          icon: LucideIcons.slidersHorizontal,
          semanticLabel: l10n.dcFilters,
          variant: AtIconButtonVariant.filter,
          showDot: _filters.activeCount > 0,
          onPressed: _openSheet,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              4,
              AtSpacing.gutter,
              0,
            ),
            child: AtTextField(
              controller: _search,
              hint: l10n.mnSearchHint,
              prefixIcon: LucideIcons.search,
              textInputAction: TextInputAction.search,
              semanticLabel: l10n.mnSearchHint,
              onSubmitted: (v) => _set(
                _filters.copyWith(q: v.trim().isEmpty ? null : v.trim()),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AtSpacing.gutter,
                vertical: 8,
              ),
              children: [
                _chip(
                  l10n.mnChipVerified,
                  _filters.verified,
                  () => _set(_filters.copyWith(verified: !_filters.verified)),
                ),
                _chip(
                  _filters.disciplineName ?? l10n.mnDiscipline,
                  _filters.disciplineId != null,
                  _openSheet,
                  dropdown: true,
                ),
                _chip(
                  l10n.mnChipAvailable,
                  _filters.availableThisWeek,
                  () => _set(
                    _filters.copyWith(
                      availableThisWeek: !_filters.availableThisWeek,
                    ),
                  ),
                ),
                _chip(
                  l10n.mnChipUnderPrice(cap),
                  _filters.maxPriceMinor != null,
                  () => _set(
                    _filters.copyWith(
                      maxPriceMinor: _filters.maxPriceMinor == null
                          ? mentorPriceCapMinor
                          : null,
                    ),
                  ),
                ),
                _chip(
                  l10n.mnChipVideo,
                  _filters.videoCall,
                  () => _set(_filters.copyWith(videoCall: !_filters.videoCall)),
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const AtLoadingBody(),
              error: (e, _) => loadFailure(
                e,
                () => ref.invalidate(mentorDirectoryProvider(_filters)),
                l10n,
              ),
              data: (page) => page.items.isEmpty
                  ? AtEmptyState(
                      icon: LucideIcons.searchX,
                      title: l10n.mnNoResults,
                      body: l10n.mnNoResultsBody,
                      ctaLabel: _filters.activeCount > 0
                          ? l10n.mnClearFilters
                          : null,
                      onCta: _filters.activeCount > 0
                          ? () => _set(_filters.cleared())
                          : null,
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(mentorDirectoryProvider(_filters));
                        await ref.read(
                          mentorDirectoryProvider(_filters).future,
                        );
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: mentorshipPadding,
                        itemCount: page.items.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AtSpacing.listGap),
                        itemBuilder: (context, i) => i == 0
                            ? Text(
                                l10n.mnCount(page.total),
                                style: AtTextStyles.meta.copyWith(
                                  color: context.at.body,
                                ),
                              )
                            : MentorCard(mentor: page.items[i - 1]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool dropdown = false,
  }) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: AtChip(
      label: label,
      selected: selected,
      kind: dropdown ? AtChipKind.dropdown : AtChipKind.selectable,
      onTap: onTap,
    ),
  );
}

class _MentorFiltersSheet extends ConsumerStatefulWidget {
  const _MentorFiltersSheet({required this.current});

  final MentorFilters current;

  @override
  ConsumerState<_MentorFiltersSheet> createState() =>
      _MentorFiltersSheetState();
}

class _MentorFiltersSheetState extends ConsumerState<_MentorFiltersSheet> {
  late MentorFilters _draft = widget.current;

  String _sortLabel(AppLocalizations l10n, MentorSort s) => switch (s) {
    MentorSort.soonest => l10n.mnSortSoonest,
    MentorSort.price => l10n.mnSortPrice,
    MentorSort.rating => l10n.mnSortRating,
    _ => l10n.mnSortRecommended,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.watch(disciplinesProvider).value ?? const [];
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
          Text(
            l10n.mnDiscipline,
            style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in disciplines)
                AtChip(
                  label: d.name,
                  selected: _draft.disciplineId == d.id,
                  onTap: () => setState(
                    () => _draft = _draft.copyWith(
                      disciplineId: _draft.disciplineId == d.id ? null : d.id,
                      disciplineName: _draft.disciplineId == d.id
                          ? null
                          : d.name,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.mnSortBy,
            style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in [
                MentorSort.recommended,
                MentorSort.soonest,
                MentorSort.price,
                MentorSort.rating,
              ])
                AtChip(
                  label: _sortLabel(l10n, s),
                  selected: _draft.sort == s,
                  onTap: () =>
                      setState(() => _draft = _draft.copyWith(sort: s)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          MentorshipToggleRow(
            label: l10n.mnChipVerified,
            value: _draft.verified,
            onChanged: (v) =>
                setState(() => _draft = _draft.copyWith(verified: v)),
          ),
          MentorshipToggleRow(
            label: l10n.mnChipAvailable,
            value: _draft.availableThisWeek,
            onChanged: (v) =>
                setState(() => _draft = _draft.copyWith(availableThisWeek: v)),
          ),
          MentorshipToggleRow(
            label: l10n.mnChipVideo,
            value: _draft.videoCall,
            onChanged: (v) =>
                setState(() => _draft = _draft.copyWith(videoCall: v)),
          ),
          MentorshipToggleRow(
            label: l10n.mnChipUnderPrice(
              formatMoney(mentorPriceCapMinor, 'KES'),
            ),
            value: _draft.maxPriceMinor != null,
            onChanged: (v) => setState(
              () => _draft = _draft.copyWith(
                maxPriceMinor: v ? mentorPriceCapMinor : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AtButton(
            label: l10n.mnShowMentors,
            onPressed: () => Navigator.of(context).pop(_draft),
          ),
          const SizedBox(height: 8),
          AtButton(
            label: l10n.mnClearFilters,
            variant: AtButtonVariant.tertiary,
            onPressed: () => Navigator.of(context).pop(_draft.cleared()),
          ),
        ],
      ),
    );
  }
}

/// A label with a switch on the right, used in the sheet and the tools.
class MentorshipToggleRow extends StatelessWidget {
  const MentorshipToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 52),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AtTextStyles.body.copyWith(color: context.at.ink),
          ),
        ),
        AtToggle(value: value, onChanged: onChanged, semanticLabel: label),
      ],
    ),
  );
}
