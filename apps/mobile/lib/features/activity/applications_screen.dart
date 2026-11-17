import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

(String, AtTone) applicationStatus(
  AppLocalizations l10n,
  ApplicationItemDtoStatus s,
) => switch (s) {
  ApplicationItemDtoStatus.applied => (l10n.ayApplied, AtTone.success),
  ApplicationItemDtoStatus.completed => (l10n.ayCompleted, AtTone.primary),
  _ => (l10n.ayInProgress, AtTone.warning),
};

/// The opportunities the member is working on or has applied for, with where each one stands.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(applicationsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(applicationsControllerProvider);
    return SubPage(
      title: l10n.ayApplicationsTitle,
      backTo: Routes.activity,
      wash: AtWash.opportunities,
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) => loadFailure(
          e,
          () => ref.invalidate(applicationsControllerProvider),
          l10n,
        ),
        data: (v) {
          if (v.items.isEmpty) {
            return AtEmptyState(
              icon: LucideIcons.briefcase,
              tone: AtTone.amber,
              title: l10n.ayApplicationsEmptyTitle,
              body: l10n.ayApplicationsEmptyBody,
              ctaLabel: l10n.ayFindOpportunities,
              onCta: () => context.go(Routes.opportunities),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(applicationsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                8,
                AtSpacing.gutter,
                32,
              ),
              itemCount: v.items.length + (v.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AtSpacing.listGap),
              itemBuilder: (context, i) {
                if (i >= v.items.length) {
                  return const AtSkeleton(height: 90, radius: 18);
                }
                final a = v.items[i];
                final (label, tone) = applicationStatus(l10n, a.status);
                return AtCard(
                  onTap: () =>
                      context.push(Routes.opportunityPath(a.opportunity.id)),
                  semanticLabel: '${a.opportunity.title}. $label',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              a.opportunity.title,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: context.at.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AtStatusPill(label: label, tone: tone),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.opportunity.provider.name,
                        style: AtTextStyles.meta.copyWith(
                          color: context.at.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 14,
                            color: context.at.body,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              a.metaLine,
                              style: AtTextStyles.metaSm.copyWith(
                                color: context.at.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
