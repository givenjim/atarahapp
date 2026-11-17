import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'opportunities_common.dart';
import 'opportunities_providers.dart';
import 'opportunities_repository.dart';
import 'opportunity_filters_sheet.dart';

/// A category of opportunities (or every one): its title, how many are open, the sort, a filters button and
/// the cards. Pages in as the member scrolls.
class OpportunitiesListScreen extends ConsumerStatefulWidget {
  const OpportunitiesListScreen({super.key, this.type});

  /// The category; null lists everything.
  final OpportunityType? type;

  @override
  ConsumerState<OpportunitiesListScreen> createState() =>
      _OpportunitiesListScreenState();
}

class _OpportunitiesListScreenState
    extends ConsumerState<OpportunitiesListScreen> {
  final _scroll = ScrollController();
  late OpportunityFilters _filters = OpportunityFilters(type: widget.type);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(opportunityListProvider(_filters).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final next = await showOpportunityFiltersSheet(context, _filters);
    if (next != null && mounted) setState(() => _filters = next);
  }

  Future<void> _openSort() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAtBottomSheet<Sort2>(
      context: context,
      title: l10n.opSortBy,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          0,
          AtSpacing.gutter,
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in [Sort2.deadline, Sort2.recent, Sort2.relevance])
              AtListRow(
                title: _sortLabel(l10n, s),
                showChevron: false,
                trailing: s == _filters.sort
                    ? Icon(LucideIcons.check, color: ctx.at.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(s),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _filters = _filters.copyWith(sort: picked));
    }
  }

  static String _sortLabel(AppLocalizations l10n, Sort2 s) => switch (s) {
    Sort2.recent => l10n.opSortRecent,
    Sort2.relevance => l10n.opSortRelevance,
    _ => l10n.opSortDeadline,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(opportunityListProvider(_filters));
    final title = opportunityCategoryLabel(l10n, widget.type);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.opportunities,
        child: Column(
          children: [
            AtTopBar(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.opportunities),
              actions: [
                AtIconButton(
                  icon: LucideIcons.slidersHorizontal,
                  semanticLabel: l10n.dcFilters,
                  variant: AtIconButtonVariant.filter,
                  showDot: _filters.activeCount > 0,
                  onPressed: _openFilters,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                4,
                AtSpacing.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: context.at.ink,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          async.hasValue
                              ? l10n.opOpenCount(
                                  async.requireValue.total,
                                  widget.type == null
                                      ? l10n.opKindAll
                                      : title.toLowerCase(),
                                )
                              : '',
                          style: AtTextStyles.meta.copyWith(
                            color: context.at.body,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: _sortLabel(l10n, _filters.sort),
                        excludeSemantics: true,
                        onTap: _openSort,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _openSort,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: AtSizes.touchTarget,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _sortLabel(l10n, _filters.sort),
                                  style: AtTextStyles.chip.copyWith(
                                    color: context.at.ink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  LucideIcons.chevronDown,
                                  size: 15,
                                  color: context.at.ink,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  () => ref.invalidate(opportunityListProvider(_filters)),
                  l10n,
                ),
                data: (page) => page.items.isEmpty
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: _filters.activeCount > 0
                            ? l10n.opNoResults
                            : l10n.opNothingOpen,
                        body: _filters.activeCount > 0
                            ? l10n.opNoResultsBody
                            : l10n.opNothingOpenBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(opportunityListProvider(_filters));
                          await ref.read(
                            opportunityListProvider(_filters).future,
                          );
                        },
                        child: ListView.separated(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AtSpacing.gutter,
                            8,
                            AtSpacing.gutter,
                            32,
                          ),
                          itemCount: page.items.length + (page.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AtSpacing.listGap),
                          itemBuilder: (context, i) => i == page.items.length
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : OpportunityTile(opportunity: page.items[i]),
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
