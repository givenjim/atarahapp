import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'learning_common.dart';
import 'learning_providers.dart';
import 'learning_repository.dart';

/// The member's own learning: how much is in progress and done, the hours this month (from real progress), and the
/// Active, Completed and Saved lists with progress bars.
class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key, this.initial = MyLearningTab.active});

  final MyLearningTab initial;

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen> {
  late MyLearningTab _tab = widget.initial;

  Future<void> _refresh() async {
    ref
      ..invalidate(learningStatsProvider)
      ..invalidate(myLearningProvider(_tab));
    await ref.read(myLearningProvider(_tab).future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(learningStatsProvider);
    final list = ref.watch(myLearningProvider(_tab));
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.learning,
        child: Column(
          children: [
            AtTopBar(
              title: l10n.lnMyLearning,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.learning),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    4,
                    AtSpacing.gutter,
                    32,
                  ),
                  children: [
                    _Stats(stats: stats.value),
                    const SizedBox(height: 16),
                    AtSegmented(
                      labels: [
                        l10n.lnTabActive,
                        l10n.lnTabCompleted,
                        l10n.lnTabSaved,
                      ],
                      selectedIndex: _tab.index,
                      onChanged: (i) =>
                          setState(() => _tab = MyLearningTab.values[i]),
                    ),
                    const SizedBox(height: 16),
                    list.when(
                      skipLoadingOnReload: true,
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => SizedBox(
                        height: 320,
                        child: loadFailure(
                          e,
                          () => ref.invalidate(myLearningProvider(_tab)),
                          l10n,
                        ),
                      ),
                      data: (page) => page.items.isEmpty
                          ? SizedBox(height: 340, child: _Empty(tab: _tab))
                          : Column(
                              children: [
                                for (final item in page.items) ...[
                                  LabTile(
                                    lab: item.content,
                                    footer: _footer(context, item),
                                  ),
                                  const SizedBox(height: AtSpacing.listGap),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _footer(BuildContext context, MyLearningItemDto item) {
    final l10n = AppLocalizations.of(context);
    final at = item.lastActivityAt;
    if (at == null || _tab == MyLearningTab.saved) return null;
    final date = shortDate(context, at.toLocal());
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _tab == MyLearningTab.completed
            ? l10n.lnCompletedOn(date)
            : l10n.lnLastActive(date),
        style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});

  final LearningStatsDto? stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String hours(num h) =>
        h == h.roundToDouble() ? '${h.toInt()}' : h.toStringAsFixed(1);
    return Row(
      children: [
        Expanded(
          child: AtStatTile(
            value: '${stats?.inProgress.toInt() ?? 0}',
            label: l10n.lnStatInProgress,
            icon: LucideIcons.bookOpen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AtStatTile(
            value: '${stats?.completed.toInt() ?? 0}',
            label: l10n.lnStatCompleted,
            icon: LucideIcons.circleCheck,
            tone: AtTone.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AtStatTile(
            value: hours(stats?.hoursThisMonth ?? 0),
            label: l10n.lnStatHours,
            icon: LucideIcons.clock,
            tone: AtTone.amber,
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab});

  final MyLearningTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (tab) {
      MyLearningTab.active => AtEmptyState(
        icon: LucideIcons.bookOpen,
        title: l10n.lnEmptyActiveTitle,
        body: l10n.lnEmptyActiveBody,
        ctaLabel: l10n.lnEmptyActiveCta,
        onCta: () => context.go(Routes.learning),
      ),
      MyLearningTab.completed => AtEmptyState(
        icon: LucideIcons.award,
        title: l10n.lnEmptyCompletedTitle,
        body: l10n.lnEmptyCompletedBody,
        tone: AtTone.success,
      ),
      MyLearningTab.saved => AtEmptyState(
        icon: LucideIcons.bookmark,
        title: l10n.lnEmptySavedTitle,
        body: l10n.lnEmptySavedBody,
        tone: AtTone.amber,
      ),
    };
  }
}
