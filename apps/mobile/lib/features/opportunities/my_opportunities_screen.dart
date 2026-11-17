import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../../shared/widgets/domain_cards.dart';
import '../discover/discover_common.dart';
import 'opportunities_common.dart';
import 'opportunities_providers.dart';
import 'opportunities_repository.dart';

/// The member's own opportunities: All, Closing soon, Applied and Completed, or (opened from the bookmark on
/// the Opportunities tab) just the saved ones. Each item says where the member is with it.
class MyOpportunitiesScreen extends ConsumerStatefulWidget {
  const MyOpportunitiesScreen({super.key, this.initial = MyTab.all});

  final MyTab initial;

  @override
  ConsumerState<MyOpportunitiesScreen> createState() =>
      _MyOpportunitiesScreenState();
}

class _MyOpportunitiesScreenState extends ConsumerState<MyOpportunitiesScreen> {
  static const _tabs = [
    MyTab.all,
    MyTab.closing,
    MyTab.applied,
    MyTab.completed,
  ];

  final _scroll = ScrollController();
  late MyTab _tab = widget.initial;

  bool get _savedView => widget.initial == MyTab.saved;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(myOpportunitiesProvider(_tab).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  (String, String) _empty(AppLocalizations l10n) => switch (_tab) {
    MyTab.closing => (l10n.opEmptyClosing, l10n.opEmptyClosingBody),
    MyTab.applied => (l10n.opEmptyApplied, l10n.opEmptyAppliedBody),
    MyTab.completed => (l10n.opEmptyCompleted, l10n.opEmptyCompletedBody),
    MyTab.saved => (l10n.opEmptySaved, l10n.opEmptySavedBody),
    MyTab.all => (l10n.opEmptyAll, l10n.opEmptyAllBody),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myOpportunitiesProvider(_tab));
    final counts = async.value?.counts;
    final labels = [
      l10n.opTabAll,
      l10n.opTabClosing,
      l10n.opTabApplied,
      l10n.opTabCompleted,
    ];
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
                        _savedView ? l10n.opSavedTitle : l10n.opMineTitle,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: context.at.ink,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  if (!_savedView) ...[
                    const SizedBox(height: 14),
                    AtSegmented(
                      labels: labels,
                      selectedIndex: _tabs.indexOf(_tab),
                      onChanged: (i) => setState(() => _tab = _tabs[i]),
                    ),
                    if (counts != null && counts.all > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.opMineSummary(
                          counts.saved,
                          counts.applied,
                          counts.completed,
                        ),
                        style: AtTextStyles.metaSm.copyWith(
                          color: context.at.muted,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(myOpportunitiesProvider(_tab)),
                  l10n,
                ),
                data: (page) {
                  if (page.items.isEmpty) {
                    final (title, body) = _empty(l10n);
                    return AtEmptyState(
                      icon: _tab == MyTab.completed
                          ? LucideIcons.trophy
                          : LucideIcons.bookmark,
                      title: title,
                      body: body,
                      ctaLabel: l10n.opExplore,
                      onCta: () => context.go(Routes.opportunities),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(myOpportunitiesProvider(_tab));
                      await ref.read(myOpportunitiesProvider(_tab).future);
                    },
                    child: ListView.separated(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AtSpacing.gutter,
                        16,
                        AtSpacing.gutter,
                        32,
                      ),
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AtSpacing.listGap),
                      itemBuilder: (context, i) => _MyItem(item: page.items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyItem extends ConsumerWidget {
  const _MyItem({required this.item});

  final MyOpportunityDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final o = item.opportunity;
    final t = item.tracking;
    final urgency = urgencyOf(o.urgency);
    final (label, tone) = switch (t.status) {
      OpportunityTrackingStatus.applied => (
        l10n.opStatusAppliedOn(
          shortDate(context, (t.appliedAt ?? DateTime.now()).toLocal()),
        ),
        AtTone.success,
      ),
      OpportunityTrackingStatus.completed => (
        l10n.opStatusCompletedOutcome(
          outcomeLabel(l10n, t.outcome ?? OpportunityOutcome.unknown),
        ),
        AtTone.success,
      ),
      OpportunityTrackingStatus.inProgress => (
        l10n.opStatusInProgress,
        AtTone.primary,
      ),
      _ =>
        urgency != DeadlineUrgency.none && o.daysLeft != null
            ? (
                l10n.opStatusClosingIn(o.daysLeft!.toInt()),
                urgencyTone(urgency),
              )
            : (
                l10n.opStatusSavedLeft(
                  deadlineText(
                    context,
                    deadlineAt: o.deadlineAt,
                    daysLeft: o.daysLeft,
                    closed: o.closed,
                  ),
                ),
                AtTone.primary,
              ),
    };
    final applied = t.status == OpportunityTrackingStatus.applied;
    return OpportunityTile(
      opportunity: o,
      footer: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AtStatusPill(label: label, tone: tone),
          if (applied)
            AtButton(
              label: l10n.opMarkCompleted,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () => completeFlow(context, ref, o.id),
            ),
        ],
      ),
    );
  }
}

/// Asks how an application went, records it, and (for a win) offers to add it to the member's achievements.
Future<void> completeFlow(
  BuildContext context,
  WidgetRef ref,
  String opportunityId,
) async {
  final outcome = await showAtBottomSheet<OpportunityOutcome>(
    context: context,
    title: AppLocalizations.of(context).opOutcomeTitle,
    builder: (_) => const _OutcomeSheet(),
  );
  if (outcome == null || !context.mounted) return;
  try {
    await ref
        .read(opportunityActionsProvider)
        .track(
          opportunityId,
          OpportunityTrackingStatus.completed,
          outcome: outcome,
        );
  } on Object catch (e) {
    if (context.mounted) showOpportunityNotice(context, opportunityError(e));
    return;
  }
  if (outcome != OpportunityOutcome.awarded || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  final add = await showAtModal<bool>(
    context: context,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: AtIconTileLarge(
            icon: LucideIcons.trophy,
            tone: AtTone.primary,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.opAwardedTitle,
            textAlign: TextAlign.center,
            style: AtTextStyles.detailTitle.copyWith(color: ctx.at.ink),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.opAwardedBody,
          textAlign: TextAlign.center,
          style: AtTextStyles.body.copyWith(color: ctx.at.body),
        ),
        const SizedBox(height: 16),
        AtButton(
          label: l10n.opAddAchievement,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        const SizedBox(height: 4),
        AtButton(
          label: l10n.opNotNow,
          variant: AtButtonVariant.tertiary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    ),
  );
  if (add == true && context.mounted) {
    await context.push(Routes.achievements);
  }
}

class _OutcomeSheet extends StatefulWidget {
  const _OutcomeSheet();

  @override
  State<_OutcomeSheet> createState() => _OutcomeSheetState();
}

class _OutcomeSheetState extends State<_OutcomeSheet> {
  OpportunityOutcome? _chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        0,
        AtSpacing.gutter,
        24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final o in [
            OpportunityOutcome.awarded,
            OpportunityOutcome.notSelected,
            OpportunityOutcome.withdrawn,
            OpportunityOutcome.unknown,
          ])
            AtListRow(
              title: outcomeLabel(l10n, o),
              showChevron: false,
              trailing: _chosen == o
                  ? Icon(LucideIcons.check, color: context.at.primary)
                  : null,
              onTap: () => setState(() => _chosen = o),
            ),
          const SizedBox(height: 12),
          AtButton(
            label: l10n.opOutcomeSave,
            onPressed: _chosen == null
                ? null
                : () => Navigator.of(context).pop(_chosen),
          ),
        ],
      ),
    );
  }
}
