import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../discover/discover_common.dart';
import '../../onboarding/onboarding_providers.dart';
import 'people_providers.dart';
import 'people_repository.dart';
import 'people_widgets.dart';

/// The People tab of the Community screen: people to meet (with a reason each), filters, and the way into
/// connections, requests and blocked people. It scrolls by itself and fills the space it is given.
class PeopleTab extends StatelessWidget {
  const PeopleTab({super.key});

  @override
  Widget build(BuildContext context) => const PeopleBody();
}

/// The body shared by the People tab and the "People to meet" screen.
class PeopleBody extends ConsumerStatefulWidget {
  const PeopleBody({super.key, this.header});

  /// Shown at the top of the list (the standalone screen puts its title here).
  final Widget? header;

  @override
  ConsumerState<PeopleBody> createState() => _PeopleBodyState();
}

class _PeopleBodyState extends ConsumerState<PeopleBody> {
  final _scroll = ScrollController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(peopleSuggestionsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _connect(String handle) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final failure = await ref
        .read(peopleSuggestionsProvider.notifier)
        .connect(handle);
    if (!mounted) return;
    if (failure == null) {
      ref.read(analyticsProvider).track('connection_action');
    } else {
      setState(() => _error = peopleFailureMessage(l10n, failure));
    }
  }

  Future<void> _openMore() async {
    final l10n = AppLocalizations.of(context);
    await showAtBottomSheet<void>(
      context: context,
      title: l10n.peopleMore,
      builder: (ctx) => OverflowSheet(
        onBlocked: () {
          Navigator.of(ctx).pop();
          context.push(Routes.blocked);
        },
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(incomingRequestCountProvider);
    ref.invalidate(peopleSuggestionsProvider);
    try {
      await ref.read(peopleSuggestionsProvider.future);
    } on Object {
      // The list shows its own error.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(peopleFiltersProvider);
    final list = ref.watch(peopleSuggestionsProvider);
    final incoming = ref.watch(incomingRequestCountProvider).value ?? 0;
    const pad = EdgeInsets.symmetric(horizontal: AtSpacing.gutter);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ?widget.header,
          Padding(
            padding: EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              widget.header == null ? 8 : 0,
              AtSpacing.gutter,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _LinkTile(
                    icon: LucideIcons.users,
                    label: l10n.peopleConnections,
                    onTap: () => context.push(Routes.connectionsPath()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LinkTile(
                    icon: LucideIcons.userPlus,
                    label: l10n.peopleRequests,
                    count: incoming,
                    countLabel: incoming > 0
                        ? l10n.peopleRequestsWaiting(incoming)
                        : null,
                    onTap: () =>
                        context.push(Routes.connectionsPath(list: 'received')),
                  ),
                ),
                const SizedBox(width: 6),
                AtIconButton(
                  icon: LucideIcons.ellipsis,
                  semanticLabel: l10n.peopleMore,
                  onPressed: _openMore,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PeopleFilterBar(filters: filters),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: pad,
              child: AtInlineBanner(message: _error!),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (list.value != null && list.value!.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      l10n.peopleCount(list.value!.total),
                      style: AtTextStyles.chip.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ),
                PagedSection<PersonRow>(
                  async: list,
                  retry: () => ref.invalidate(peopleSuggestionsProvider),
                  loadMore: () =>
                      ref.read(peopleSuggestionsProvider.notifier).loadMore(),
                  empty: () => filters.isEmpty
                      ? AtEmptyState(
                          icon: LucideIcons.users,
                          title: l10n.peopleEmptyTitle,
                          body: l10n.peopleEmptyBody,
                        )
                      : AtEmptyState(
                          icon: LucideIcons.users,
                          title: l10n.peopleEmptyFilteredTitle,
                          body: l10n.peopleEmptyFilteredBody,
                          ctaLabel: l10n.peopleClearFilters,
                          onCta: () =>
                              ref.read(peopleFiltersProvider.notifier).reset(),
                        ),
                  item: (row) => PersonCard(
                    row: row,
                    onConnect: () => _connect(row.person.handle),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count = 0,
    this.countLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int count;
  final String? countLabel;

  @override
  Widget build(BuildContext context) => AtCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    semanticLabel: countLabel == null ? label : '$label, $countLabel',
    labelReplacesContent: true,
    child: Row(
      children: [
        Icon(icon, size: 18, color: context.at.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtTextStyles.chip.copyWith(color: context.at.ink),
          ),
        ),
        if (count > 0) CountPill(count: count),
      ],
    ),
  );
}

/// Discipline, county, verified and open to work.
class PeopleFilterBar extends ConsumerWidget {
  const PeopleFilterBar({super.key, required this.filters});

  final PeopleFilters filters;

  Future<void> _pickDiscipline(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final disciplines = ref.read(disciplinesProvider).value ?? const [];
    final picked = await showAtBottomSheet<_Pick>(
      context: context,
      title: l10n.dcDiscipline,
      builder: (ctx) => _PickList(
        allLabel: l10n.peopleAnyDiscipline,
        selected: filters.disciplineId,
        options: [for (final d in disciplines) (d.id, d.name)],
      ),
    );
    if (picked == null) return;
    ref
        .read(peopleFiltersProvider.notifier)
        .set(
          filters.copyWith(
            disciplineId: picked.id,
            disciplineName: picked.name,
          ),
        );
  }

  Future<void> _pickCounty(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final counties = ref.read(countyOptionsProvider(null)).value ?? const [];
    final picked = await showAtBottomSheet<_Pick>(
      context: context,
      title: l10n.dcCounty,
      builder: (ctx) => _PickList(
        allLabel: l10n.peopleAnyCounty,
        selected: filters.countyId,
        options: [for (final c in counties) (c.id, c.name)],
      ),
    );
    if (picked == null) return;
    ref
        .read(peopleFiltersProvider.notifier)
        .set(filters.copyWith(countyId: picked.id, countyName: picked.name));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(peopleFiltersProvider.notifier);
    // Watched so the options are loaded by the time a chip is tapped.
    ref.watch(disciplinesProvider);
    ref.watch(countyOptionsProvider(null));
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
        children: [
          AtChip(
            label: filters.disciplineName ?? l10n.dcDiscipline,
            kind: AtChipKind.dropdown,
            selected: filters.disciplineId != null,
            onTap: () => _pickDiscipline(context, ref),
          ),
          const SizedBox(width: 8),
          AtChip(
            label: filters.countyName ?? l10n.dcCounty,
            kind: AtChipKind.dropdown,
            selected: filters.countyId != null,
            onTap: () => _pickCounty(context, ref),
          ),
          const SizedBox(width: 8),
          AtChip(
            label: l10n.verified,
            selected: filters.verified,
            onTap: () =>
                notifier.set(filters.copyWith(verified: !filters.verified)),
          ),
          const SizedBox(width: 8),
          AtChip(
            label: l10n.peopleOpenToWork,
            selected: filters.available,
            onTap: () =>
                notifier.set(filters.copyWith(available: !filters.available)),
          ),
        ],
      ),
    );
  }
}

/// The sheet's answer: an option, or null id for "all".
class _Pick {
  const _Pick(this.id, this.name);
  final String? id;
  final String? name;
}

class _PickList extends StatelessWidget {
  const _PickList({
    required this.allLabel,
    required this.selected,
    required this.options,
  });

  final String allLabel;
  final String? selected;
  final List<(String, String)> options;

  @override
  Widget build(BuildContext context) {
    Widget? tick(bool on) =>
        on ? Icon(LucideIcons.check, color: context.at.primary) : null;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: ListView(
        children: [
          AtListRow(
            title: allLabel,
            showChevron: false,
            trailing: tick(selected == null),
            onTap: () => Navigator.of(context).pop(const _Pick(null, null)),
          ),
          for (final (id, name) in options)
            AtListRow(
              title: name,
              showChevron: false,
              trailing: tick(id == selected),
              onTap: () => Navigator.of(context).pop(_Pick(id, name)),
            ),
        ],
      ),
    );
  }
}

/// One suggested person: who they are, why they are suggested, Save (soon) and Connect / Requested.
class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.row, required this.onConnect});

  final PersonRow row;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = row.person;
    final role = c.headline ?? c.discipline?.name;
    void open() => context.push(Routes.creativePath(c.handle));

    final button = switch (row.rel) {
      PersonRel.none => AtButton(
        label: l10n.cpConnect,
        size: AtButtonSize.sm,
        fullWidth: false,
        icon: LucideIcons.userPlus,
        semanticLabel: l10n.peopleConnectWith(c.displayName),
        onPressed: onConnect,
      ),
      PersonRel.requested => AtButton(
        label: l10n.peopleRequested,
        variant: AtButtonVariant.secondary,
        size: AtButtonSize.sm,
        fullWidth: false,
        icon: LucideIcons.clock,
        onPressed: null,
      ),
      PersonRel.connected => AtButton(
        label: l10n.cpConnected,
        variant: AtButtonVariant.secondary,
        size: AtButtonSize.sm,
        fullWidth: false,
        icon: LucideIcons.check,
        onPressed: null,
      ),
      PersonRel.incoming => AtButton(
        label: l10n.peopleRespond,
        size: AtButtonSize.sm,
        fullWidth: false,
        onPressed: open,
      ),
    };

    return AtCard(
      onTap: open,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Portrait(name: c.displayName, url: c.avatarUrl, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AtTextStyles.cardTitle.copyWith(
                              color: context.at.ink,
                            ),
                          ),
                        ),
                        if (c.verified) ...[
                          const SizedBox(width: 6),
                          const AtVerifiedTick(),
                        ],
                      ],
                    ),
                    if (role != null)
                      Text(
                        role,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.bodySm.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    if (c.reason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        c.reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.metaSm.copyWith(
                          color: context.at.primary,
                        ),
                      ),
                    ],
                    if (c.location != null || c.openToCommissions) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 10,
                        children: [
                          if (c.location != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 12,
                                  color: context.at.muted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  c.location!,
                                  style: AtTextStyles.metaSm.copyWith(
                                    color: context.at.muted,
                                  ),
                                ),
                              ],
                            ),
                          if (c.openToCommissions)
                            Text(
                              l10n.peopleOpenToWork,
                              style: AtTextStyles.metaSm.copyWith(
                                color: context.at.successStrong,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              button,
              const Spacer(),
              // Saving a person is not built yet: it opens the "Soon" screen rather than pretending to save.
              AtTapTarget(
                semanticLabel: l10n.peopleSaveLabel(c.displayName),
                onTap: () => context.push(
                  Routes.soonPath('later', name: l10n.peopleSaveFeature),
                ),
                child: Icon(
                  LucideIcons.bookmark,
                  size: 20,
                  color: context.at.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
