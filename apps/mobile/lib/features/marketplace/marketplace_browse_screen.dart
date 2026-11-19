import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'marketplace_common.dart';
import 'marketplace_providers.dart';
import 'marketplace_repository.dart';

/// `market_browse`: a category title and count, a sort, a filters sheet, and two-column cards with save.
class MarketplaceBrowseScreen extends ConsumerStatefulWidget {
  const MarketplaceBrowseScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.type,
    this.q,
  });

  final String? categoryId;
  final String? categoryName;
  final ListingType? type;
  final String? q;

  @override
  ConsumerState<MarketplaceBrowseScreen> createState() =>
      _MarketplaceBrowseScreenState();
}

class _MarketplaceBrowseScreenState
    extends ConsumerState<MarketplaceBrowseScreen> {
  late ListingFilters _filters = ListingFilters(
    categoryId: widget.categoryId,
    categoryName: widget.categoryName,
    type: widget.type,
    q: widget.q,
  );
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(listingListProvider(_filters).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _sort() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAtBottomSheet<ListingSort>(
      context: context,
      title: l10n.mkSortLabel,
      builder: (ctx) => Column(
        children: [
          for (final s in ListingSort.values.where(
            (s) => s != ListingSort.$unknown,
          ))
            AtRadioCard(
              title: sortLabel(l10n, s),
              selected: s == _filters.sort,
              onTap: () => Navigator.of(ctx).pop(s),
            ),
        ],
      ),
    );
    if (picked != null) {
      setState(() => _filters = _filters.copyWith(sort: picked));
    }
  }

  Future<void> _openFilters() async {
    final l10n = AppLocalizations.of(context);
    final next = await showAtBottomSheet<ListingFilters>(
      context: context,
      title: l10n.mkFilters,
      builder: (_) => _FiltersSheet(initial: _filters),
    );
    if (next != null) setState(() => _filters = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(listingListProvider(_filters));
    final title =
        _filters.categoryName ??
        switch (_filters.type) {
          ListingType.service => l10n.mkSegServices,
          ListingType.product => l10n.mkSegProducts,
          _ => l10n.mkBrowseAll,
        };
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            MkTopBar(
              title: title,
              actions: [
                AtIconButton(
                  icon: LucideIcons.slidersHorizontal,
                  semanticLabel: l10n.mkFilters,
                  badge: _filters.activeCount,
                  onPressed: _openFilters,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AtSpacing.gutter,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      async.value == null
                          ? ''
                          : l10n.mkResultCount(async.value!.total),
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ),
                  AtChip(
                    label: sortLabel(l10n, _filters.sort),
                    icon: LucideIcons.arrowUpDown,
                    onTap: _sort,
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
                  () => ref.invalidate(listingListProvider(_filters)),
                  l10n,
                ),
                data: (list) => list.items.isEmpty
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: l10n.mkNoResultsTitle,
                        body: l10n.mkNoResultsBody,
                        ctaLabel: _filters.activeCount > 0
                            ? l10n.mkClearFilters
                            : null,
                        onCta: _filters.activeCount > 0
                            ? () => setState(
                                () => _filters = _filters.copyWith(
                                  type: null,
                                  minPrice: null,
                                  maxPrice: null,
                                  remote: false,
                                ),
                              )
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(listingListProvider(_filters));
                          await ref.read(listingListProvider(_filters).future);
                        },
                        child: ListView(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 32),
                          children: [
                            ListingGrid(items: list.items),
                            if (list.loadingMore)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (list.moreFailed)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: AtButton(
                                  label: l10n.retry,
                                  variant: AtButtonVariant.secondary,
                                  onPressed: () => ref
                                      .read(
                                        listingListProvider(_filters).notifier,
                                      )
                                      .loadMore(),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});

  final ListingFilters initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late ListingType? _type = widget.initial.type;
  late bool _remote = widget.initial.remote;
  late final _min = TextEditingController(
    text: widget.initial.minPrice?.toString() ?? '',
  );
  late final _max = TextEditingController(
    text: widget.initial.maxPrice?.toString() ?? '',
  );

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.mkFilterType,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        AtSegmented(
          labels: [l10n.mkTypeAll, l10n.mkSegServices, l10n.mkSegProducts],
          selectedIndex: switch (_type) {
            ListingType.service => 1,
            ListingType.product => 2,
            _ => 0,
          },
          onChanged: (i) => setState(
            () => _type = switch (i) {
              1 => ListingType.service,
              2 => ListingType.product,
              _ => null,
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.mkFilterPrice,
          style: AtTextStyles.label.copyWith(color: context.at.ink),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AtTextField(
                label: l10n.mkFilterMin,
                controller: _min,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 9,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AtTextField(
                label: l10n.mkFilterMax,
                controller: _max,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AtCheckbox(
          value: _remote,
          label: l10n.mkFilterRemote,
          onChanged: (v) => setState(() => _remote = v),
        ),
        const SizedBox(height: 20),
        AtButton(
          label: l10n.mkApplyFilters,
          onPressed: () => Navigator.of(context).pop(
            widget.initial.copyWith(
              type: _type,
              minPrice: int.tryParse(_min.text.trim()),
              maxPrice: int.tryParse(_max.text.trim()),
              remote: _remote,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AtButton(
          label: l10n.mkClearFilters,
          variant: AtButtonVariant.tertiary,
          onPressed: () => Navigator.of(context).pop(
            widget.initial.copyWith(
              type: null,
              minPrice: null,
              maxPrice: null,
              remote: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// Used by the router: parses the `type` query value.
ListingType? listingTypeOf(String? json) => ListingType.values
    .where((t) => t.json != null && t.json == json)
    .firstOrNull;

/// Shown when a failure should say what happened in the person's words.
String failureText(Object e) =>
    e is AppFailure ? e.message : const UnexpectedFailure().message;

/// Opens the "Request" screen; kept here so screens share one path.
void openEnquiry(BuildContext context, String id) =>
    context.push(Routes.enquiryPath(id));
