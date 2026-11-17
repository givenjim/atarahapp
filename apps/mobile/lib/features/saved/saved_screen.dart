import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/notification_route.dart';
import '../../core/routing/routes.dart';
import '../../shared/widgets/domain_cards.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

(IconData, AtTone) savedLook(SavedKind k) => switch (k) {
  SavedKind.opportunity => (LucideIcons.briefcase, AtTone.amber),
  SavedKind.learning => (LucideIcons.graduationCap, AtTone.success),
  SavedKind.creative => (LucideIcons.user, AtTone.indigo),
  SavedKind.article => (LucideIcons.bookOpen, AtTone.violet),
  SavedKind.post => (LucideIcons.messageSquare, AtTone.primary),
  SavedKind.listing => (LucideIcons.shoppingBag, AtTone.coral),
  _ => (LucideIcons.users, AtTone.violet),
};

String savedTypeLabel(AppLocalizations l10n, SavedKind k) => switch (k) {
  SavedKind.opportunity => l10n.sdTypeOpportunity,
  SavedKind.learning => l10n.sdTypeLearning,
  SavedKind.creative => l10n.sdTypeCreative,
  SavedKind.article => l10n.sdTypeArticle,
  SavedKind.post => l10n.sdTypePost,
  SavedKind.listing => l10n.sdTypeListing,
  _ => l10n.sdTypeMentor,
};

/// The chips, in order. Listings and mentors open their "Soon" screens (the Marketplace and Mentorship arrive in
/// Phase 2); everything else filters the list.
const _chips = [
  SavedKind.opportunity,
  SavedKind.learning,
  SavedKind.creative,
  SavedKind.article,
  SavedKind.post,
  SavedKind.listing,
  SavedKind.mentor,
];

/// Everything the member saved, whatever it is. One list for every save button in the app.
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(savedControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _chip(SavedKind k) {
    if (k == SavedKind.listing || k == SavedKind.mentor) {
      final l10n = AppLocalizations.of(context);
      context.push(Routes.soonPath('p2', name: savedTypeLabel(l10n, k)));
      return;
    }
    ref.read(savedControllerProvider.notifier).select(k);
  }

  Future<void> _unsave(SavedItemDto item) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(savedControllerProvider.notifier).unsave(item);
    } on Object catch (e) {
      // The row is back; say why.
      if (mounted) {
        showNotice(context, '${l10n.sdUnsaveFailed} ${failureMessage(e)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(savedControllerProvider);
    final type = async.value?.type;
    return SubPage(
      title: l10n.sdTitle,
      backTo: Routes.profile,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
              children: [
                AtChip(
                  label: l10n.sdAll,
                  selected: type == null,
                  onTap: () =>
                      ref.read(savedControllerProvider.notifier).select(null),
                ),
                for (final k in _chips) ...[
                  const SizedBox(width: 8),
                  AtChip(
                    label: savedTypeLabel(l10n, k),
                    selected: type == k,
                    onTap: () => _chip(k),
                  ),
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
                () => ref.invalidate(savedControllerProvider),
                l10n,
              ),
              data: (v) {
                if (v.items.isEmpty) {
                  return AtEmptyState(
                    icon: LucideIcons.bookmark,
                    title: type == null
                        ? l10n.sdEmptyTitle
                        : l10n.sdEmptyTypeTitle(savedTypeLabel(l10n, type)),
                    body: l10n.sdEmptyBody,
                    ctaLabel: l10n.sdExplore,
                    onCta: () => context.go(Routes.explore),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(savedControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AtSpacing.gutter,
                      16,
                      AtSpacing.gutter,
                      32,
                    ),
                    itemCount:
                        v.items.length +
                        (v.loadingMore || v.moreFailed ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AtSpacing.listGap),
                    itemBuilder: (context, i) {
                      if (i >= v.items.length) {
                        return v.moreFailed
                            ? AtButton(
                                label: l10n.retry,
                                variant: AtButtonVariant.secondary,
                                size: AtButtonSize.sm,
                                fullWidth: false,
                                onPressed: () => ref
                                    .read(savedControllerProvider.notifier)
                                    .loadMore(),
                              )
                            : const AtSkeleton(height: 64, radius: 16);
                      }
                      final s = v.items[i];
                      final (icon, tone) = savedLook(s.type);
                      return SavedItemRow(
                        typeLabel: savedTypeLabel(l10n, s.type),
                        title: s.title,
                        meta: s.subtitle ?? '',
                        icon: icon,
                        tone: tone,
                        onTap: () {
                          final route = resolveNotificationRoute(s.path);
                          if (route != null) context.push(route);
                        },
                        onUnsave: () => _unsave(s),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
