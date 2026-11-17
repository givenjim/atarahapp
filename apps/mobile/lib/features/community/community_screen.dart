import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import 'community_providers.dart';
import 'groups/groups_tab.dart';
import 'people/people_providers.dart';
import 'people/people_tab.dart';
import 'post_card.dart';

enum _Tab { feed, discussions, groups, people }

/// The Community tab: a header with "+" to compose, the Feed / Discussions / Groups / People chips, and the
/// chosen list below. Groups and People are built in their own folders and embedded here.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  _Tab _tab = _Tab.feed;

  String _label(AppLocalizations l10n, _Tab t) => switch (t) {
    _Tab.feed => l10n.cfdTabFeed,
    _Tab.discussions => l10n.cfdTabDiscussions,
    _Tab.groups => l10n.cfdTabGroups,
    _Tab.people => l10n.cfdTabPeople,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final incoming = ref.watch(incomingRequestCountProvider).value ?? 0;
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                14,
                AtSpacing.gutter,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.cfdTitle,
                            style: AtTextStyles.tabTitle.copyWith(
                              color: context.at.ink,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.cfdSubtitle,
                          style: AtTextStyles.body.copyWith(
                            color: context.at.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AtIconButton(
                    icon: LucideIcons.plus,
                    semanticLabel: l10n.cfdNewPost,
                    variant: AtIconButtonVariant.gradient,
                    onPressed: () => context.push(Routes.compose),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                ),
                children: [
                  for (final t in _Tab.values) ...[
                    if (t != _Tab.feed) const SizedBox(width: 8),
                    AtChip(
                      label: t == _Tab.people && incoming > 0
                          ? '${_label(l10n, t)} · $incoming'
                          : _label(l10n, t),
                      selected: _tab == t,
                      onTap: () => setState(() => _tab = t),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: switch (_tab) {
                _Tab.feed => const _FeedList(key: ValueKey('feed'), type: null),
                _Tab.discussions => const _FeedList(
                  key: ValueKey('discussions'),
                  type: PostType.discussion,
                ),
                _Tab.groups => const GroupsTab(),
                _Tab.people => const PeopleTab(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The posts of the Feed tab (all types) or the Discussions tab (discussions only), with pull to refresh and
/// more posts as the member scrolls.
class _FeedList extends ConsumerStatefulWidget {
  const _FeedList({super.key, required this.type});

  final PostType? type;

  @override
  ConsumerState<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<_FeedList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(feedProvider(widget.type).notifier).loadMore();
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
    final feed = ref.watch(feedProvider(widget.type));
    final overrides = ref.watch(postOverridesProvider);
    final isFeed = widget.type == null;

    Widget body(List<Widget> children) => RefreshIndicator(
      onRefresh: () => ref.read(feedProvider(widget.type).notifier).refresh(),
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          16,
          AtSpacing.gutter,
          32,
        ),
        children: children,
      ),
    );

    return feed.when(
      loading: () => body([
        if (isFeed) const _ComposerPrompt(),
        for (var i = 0; i < 3; i++) ...const [
          SizedBox(height: 14),
          AtSkeleton(height: 190, radius: 18),
        ],
      ]),
      error: (e, _) => body([
        if (isFeed) const _ComposerPrompt(),
        const SizedBox(height: 24),
        e is NetworkFailure
            ? AtErrorState(
                title: l10n.cfdOfflineTitle,
                body: l10n.cfdOfflineBody,
                ctaLabel: l10n.retry,
                onCta: () => ref.invalidate(feedProvider(widget.type)),
              )
            : AtErrorState(
                title: l10n.cfdFeedFailed,
                body: e is AppFailure
                    ? e.message
                    : const UnexpectedFailure().message,
                ctaLabel: l10n.retry,
                onCta: () => ref.invalidate(feedProvider(widget.type)),
              ),
      ]),
      data: (page) {
        final posts = [
          for (final p in page.items)
            if (!overrides.removed.contains(p.id)) p,
        ];
        return body([
          if (isFeed) const _ComposerPrompt(),
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AtEmptyState(
                icon: isFeed
                    ? LucideIcons.messagesSquare
                    : LucideIcons.messageCircle,
                title: isFeed ? l10n.cfdFeedEmpty : l10n.cfdDiscussionsEmpty,
                body: isFeed
                    ? l10n.cfdFeedEmptyBody
                    : l10n.cfdDiscussionsEmptyBody,
                ctaLabel: l10n.cfdWritePost,
                onCta: () => context.push(Routes.compose),
              ),
            ),
          for (final p in posts) ...[
            const SizedBox(height: 14),
            CommunityPostCard(
              post: p,
              onOpen: () => context.push(Routes.postPath(p.id)),
            ),
          ],
          if (page.loadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (page.moreFailed) ...[
            const SizedBox(height: 12),
            Text(
              l10n.cfdLoadMoreFailed,
              textAlign: TextAlign.center,
              style: AtTextStyles.bodySm.copyWith(color: context.at.muted),
            ),
            AtButton(
              label: l10n.retry,
              variant: AtButtonVariant.tertiary,
              onPressed: () =>
                  ref.read(feedProvider(widget.type).notifier).loadMore(),
            ),
          ],
        ]);
      },
    );
  }
}

/// "Share an update or ask a question…": opens the composer.
class _ComposerPrompt extends ConsumerWidget {
  const _ComposerPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(sessionControllerProvider).value?.fullName ?? '';
    return AtCard(
      onTap: () => context.push(Routes.compose),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      semanticLabel: l10n.cfdComposerPrompt,
      child: Row(
        children: [
          AtAvatar(name: name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.cfdComposerPrompt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.body.copyWith(color: context.at.muted),
            ),
          ),
          Icon(LucideIcons.image, size: 20, color: context.at.primary),
        ],
      ),
    );
  }
}
