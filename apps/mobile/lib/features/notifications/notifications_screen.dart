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
import '../community/community_common.dart' show relativeTime;
import '../community/community_providers.dart';
import '../discover/discover_common.dart';

/// What each category looks like in a row.
(IconData, AtTone) categoryLook(NotificationCategory c) => switch (c) {
  NotificationCategory.opportunities => (LucideIcons.briefcase, AtTone.amber),
  NotificationCategory.mentorship => (LucideIcons.users, AtTone.violet),
  NotificationCategory.community => (LucideIcons.messageCircle, AtTone.primary),
  NotificationCategory.learning => (LucideIcons.graduationCap, AtTone.success),
  NotificationCategory.profile => (LucideIcons.user, AtTone.indigo),
  NotificationCategory.marketplace => (LucideIcons.shoppingBag, AtTone.coral),
  _ => (LucideIcons.bell, AtTone.neutral),
};

String categoryName(AppLocalizations l10n, NotificationCategory c) =>
    switch (c) {
      NotificationCategory.opportunities => l10n.ntCatOpportunities,
      NotificationCategory.mentorship => l10n.ntCatMentorship,
      NotificationCategory.community => l10n.ntCatCommunity,
      NotificationCategory.learning => l10n.ntCatLearning,
      NotificationCategory.profile => l10n.ntCatProfile,
      NotificationCategory.marketplace => l10n.ntCatMarketplace,
      _ => l10n.ntCatSystem,
    };

/// The categories shown as chips, in the prototype's order (after "All").
const _chips = [
  NotificationCategory.opportunities,
  NotificationCategory.community,
  NotificationCategory.learning,
  NotificationCategory.mentorship,
  NotificationCategory.profile,
  NotificationCategory.system,
];

/// The notifications list: category chips, Today and Earlier, unread rows tinted with a dot. Tapping a row marks it
/// read and opens what it is about.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(notificationsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(NotificationItemDto n) {
    ref.read(notificationsControllerProvider.notifier).markRead(n);
    final route = resolveNotificationRoute(n.deepLink);
    // A notification whose target this app cannot open stays a read item in the list.
    if (route != null) context.push(route);
  }

  Future<void> _markAll(AppLocalizations l10n) async {
    try {
      await ref.read(notificationsControllerProvider.notifier).markAllRead();
    } on Object catch (e) {
      if (mounted) showNotice(context, failureMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationsControllerProvider);
    final view = async.value;
    final now = ref.watch(communityClockProvider)();
    final hasUnread = view?.items.any((n) => !n.read) ?? false;
    return SubPage(
      title: l10n.ntTitle,
      backTo: Routes.home,
      actions: [
        AtIconButton(
          icon: LucideIcons.settings2,
          semanticLabel: l10n.ntSettings,
          variant: AtIconButtonVariant.back,
          onPressed: () => context.push(Routes.notificationSettings),
        ),
      ],
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
              children: [
                AtChip(
                  label: l10n.ntAll,
                  selected: view?.category == null,
                  onTap: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .select(null),
                ),
                for (final c in _chips) ...[
                  const SizedBox(width: 8),
                  AtChip(
                    label: categoryName(l10n, c),
                    selected: view?.category == c,
                    onTap: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .select(c),
                  ),
                ],
              ],
            ),
          ),
          if (hasUnread)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AtSpacing.gutter - 6),
                child: AtButton(
                  label: l10n.ntMarkAllRead,
                  variant: AtButtonVariant.tertiary,
                  size: AtButtonSize.sm,
                  fullWidth: false,
                  onPressed: () => _markAll(l10n),
                ),
              ),
            ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const AtLoadingBody(),
              error: (e, _) => loadFailure(
                e,
                () => ref.invalidate(notificationsControllerProvider),
                l10n,
              ),
              data: (v) {
                if (v.items.isEmpty) {
                  return AtEmptyState(
                    icon: LucideIcons.bellOff,
                    title: v.category == null
                        ? l10n.ntEmptyTitle
                        : l10n.ntEmptyCategoryTitle(
                            categoryName(l10n, v.category!),
                          ),
                    body: l10n.ntEmptyBody,
                  );
                }
                final today = v.items
                    .where((n) => n.group == NotificationItemDtoGroup.today)
                    .toList();
                final earlier = v.items
                    .where((n) => n.group != NotificationItemDtoGroup.today)
                    .toList();
                Widget tile(NotificationItemDto n) {
                  final (icon, tone) = categoryLook(n.category);
                  return NotificationTile(
                    title: n.title,
                    body: n.body,
                    timeLabel: relativeTime(l10n, n.createdAt, now),
                    icon: icon,
                    tone: tone,
                    unread: !n.read,
                    onTap: () => _open(n),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .refresh(),
                  child: ListView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AtSpacing.gutter,
                      0,
                      AtSpacing.gutter,
                      32,
                    ),
                    children: [
                      if (today.isNotEmpty) ...[
                        GroupLabel(l10n.ntToday),
                        for (final n in today) ...[
                          tile(n),
                          const SizedBox(height: 8),
                        ],
                      ],
                      if (earlier.isNotEmpty) ...[
                        GroupLabel(l10n.ntEarlier),
                        for (final n in earlier) ...[
                          tile(n),
                          const SizedBox(height: 8),
                        ],
                      ],
                      if (v.loadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: AtSkeleton(height: 60, radius: 16),
                        ),
                      if (v.moreFailed)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: AtButton(
                            label: l10n.retry,
                            variant: AtButtonVariant.secondary,
                            size: AtButtonSize.sm,
                            fullWidth: false,
                            onPressed: () => ref
                                .read(notificationsControllerProvider.notifier)
                                .loadMore(),
                          ),
                        ),
                    ],
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
