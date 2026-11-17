import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/networking/failures.dart';
import '../../../core/providers.dart';
import '../../discover/discover_common.dart';
import '../../profile/profile_providers.dart';
import 'groups_common.dart';
import 'groups_providers.dart';

/// One group: cover, join and share, the pinned announcement, recent discussions and, for members, a way to
/// start a discussion in it. [groupRef] is the group's id or slug.
class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key, required this.groupRef});

  final String groupRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(groupDetailProvider(groupRef));
    return Scaffold(
      backgroundColor: context.at.background,
      body: async.when(
        loading: () => const _Frame(child: _GroupSkeleton()),
        error: (e, _) => _Frame(
          child: e is ApiFailure && e.statusCode == 404
              ? AtEmptyState(
                  icon: LucideIcons.lock,
                  title: l10n.grpGone,
                  body: l10n.grpGoneBody,
                )
              : loadFailure(
                  e,
                  () => ref.invalidate(groupDetailProvider(groupRef)),
                  l10n,
                ),
        ),
        data: (g) => _GroupBody(group: g, groupRef: groupRef),
      ),
    );
  }
}

/// A plain top bar with back, for the states that have no cover.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AtIconButton(
                icon: LucideIcons.arrowLeft,
                semanticLabel: l10n.back,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/community'),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _GroupSkeleton extends StatelessWidget {
  const _GroupSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AtSpacing.gutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtSkeleton(height: 120, radius: 20),
        SizedBox(height: 18),
        AtSkeleton(width: 220, height: 24),
        SizedBox(height: 10),
        AtSkeleton(width: 160),
        SizedBox(height: 18),
        AtSkeleton(height: 46, radius: 23),
        SizedBox(height: 18),
        AtSkeleton(height: 70, radius: 18),
        SizedBox(height: 10),
        AtSkeleton(height: 70, radius: 18),
      ],
    ),
  );
}

class _GroupBody extends ConsumerStatefulWidget {
  const _GroupBody({required this.group, required this.groupRef});

  final GroupDetailDto group;
  final String groupRef;

  @override
  ConsumerState<_GroupBody> createState() => _GroupBodyState();
}

class _GroupBodyState extends ConsumerState<_GroupBody> {
  Future<void> _share(GroupDetailDto g) async {
    final l10n = AppLocalizations.of(context);
    ref.read(analyticsProvider).track('group_shared', {'slug': g.slug});
    await ref.read(shareTextProvider)(
      '${l10n.grpShareText(g.name)}\nhttps://atarah.app/groups/${Uri.encodeComponent(g.slug)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final g = widget.group;
    final o = ref.watch(groupMembershipProvider)[g.id];
    final joined = o?.joined ?? g.viewer.joined;
    final count = o?.memberCount ?? g.memberCount;
    final isPrivate = g.visibility == GroupVisibility.private;
    final isOwner = g.viewer.role == GroupViewerDtoRole.owner;
    final canPost = joined && (g.viewer.joined ? g.viewer.canPost : true);
    final canJoin = joined || !isPrivate;
    final posts = ref.watch(groupPostsProvider(widget.groupRef));

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) {
          ref.read(groupPostsProvider(widget.groupRef).notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        edgeOffset: 80,
        onRefresh: () async {
          ref.invalidate(groupDetailProvider(widget.groupRef));
          ref.invalidate(groupPostsProvider(widget.groupRef));
        },
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: GroupCover(url: g.coverUrl, type: g.type),
                ),
                Positioned(
                  left: 14,
                  top: MediaQuery.paddingOf(context).top + 6,
                  child: AtIconButton(
                    icon: LucideIcons.arrowLeft,
                    semanticLabel: l10n.back,
                    variant: AtIconButtonVariant.glass,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/community'),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: BoxDecoration(
                  color: context.at.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  22,
                  AtSpacing.gutter,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.name,
                      style: AtTextStyles.detailTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.grpMeta(
                            groupTypeLabel(l10n, g.type),
                            l10n.grpMembers(count.toInt()),
                          ),
                          style: AtTextStyles.meta.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                        if (g.isOfficial)
                          AtTag(
                            label: l10n.grpOfficial,
                            tone: AtTone.primary,
                            icon: LucideIcons.badgeCheck,
                          ),
                        if (isPrivate)
                          AtTag(
                            label: l10n.grpTypePrivate,
                            tone: AtTone.neutral,
                            icon: LucideIcons.lock,
                          ),
                      ],
                    ),
                    if (g.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        g.description,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.longForm,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: canJoin
                              ? AtButton(
                                  label: joined
                                      ? l10n.joinedAction
                                      : l10n.grpJoinGroup,
                                  icon: joined ? LucideIcons.check : null,
                                  variant: joined
                                      ? AtButtonVariant.secondary
                                      : AtButtonVariant.primary,
                                  onPressed: () => toggleGroupMembership(
                                    context,
                                    ref,
                                    groupId: g.id,
                                    name: g.name,
                                    joined: joined,
                                    isOwner: isOwner,
                                    memberCount: count,
                                  ),
                                )
                              : Text(
                                  l10n.grpPrivateNote,
                                  style: AtTextStyles.meta.copyWith(
                                    color: context.at.muted,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        AtIconButton(
                          icon: LucideIcons.share2,
                          semanticLabel: l10n.grpShare,
                          onPressed: () => _share(g),
                        ),
                      ],
                    ),
                    if (g.pinned != null) ...[
                      const SizedBox(height: 18),
                      _Pinned(post: g.pinned!),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      l10n.grpRecent,
                      style: AtTextStyles.sectionTitleSm.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (canPost)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AtButton(
                          label: l10n.grpStartDiscussion,
                          icon: LucideIcons.squarePen,
                          variant: AtButtonVariant.secondary,
                          onPressed: () =>
                              openGroupCompose(context, g.id, g.name),
                        ),
                      )
                    else if (canJoin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.grpJoinToPost,
                          style: AtTextStyles.meta.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                      ),
                    posts.when(
                      loading: () => const Column(
                        children: [
                          AtSkeleton(height: 84, radius: 16),
                          SizedBox(height: 10),
                          AtSkeleton(height: 84, radius: 16),
                        ],
                      ),
                      error: (e, _) => AtErrorState(
                        title: l10n.grpPostsFailed,
                        body: e is AppFailure
                            ? groupFailureMessage(l10n, e)
                            : const UnexpectedFailure().message,
                        ctaLabel: l10n.retry,
                        onCta: () =>
                            ref.invalidate(groupPostsProvider(widget.groupRef)),
                      ),
                      data: (list) => list.items.isEmpty
                          ? AtEmptyState(
                              icon: LucideIcons.messagesSquare,
                              title: l10n.grpNoDiscussions,
                              body: l10n.grpNoDiscussionsBody,
                            )
                          : Column(
                              children: [
                                for (final p in list.items) ...[
                                  _DiscussionRow(post: p),
                                  const SizedBox(height: 10),
                                ],
                                if (list.hasMore)
                                  list.loadingMore
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(),
                                        )
                                      : AtButton(
                                          label: list.moreFailed
                                              ? l10n.retry
                                              : l10n.grpMoreDiscussions,
                                          variant: AtButtonVariant.secondary,
                                          onPressed: () => ref
                                              .read(
                                                groupPostsProvider(
                                                  widget.groupRef,
                                                ).notifier,
                                              )
                                              .loadMore(),
                                        ),
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
}

/// The latest pinned announcement.
class _Pinned extends StatelessWidget {
  const _Pinned({required this.post});

  final PostViewDto post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.grpPinned,
      child: InkWell(
        borderRadius: AtRadii.cardLg,
        onTap: () => context.push('/posts/${Uri.encodeComponent(post.id)}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.at.primaryTintFaint,
            borderRadius: AtRadii.cardLg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.pin, size: 18, color: context.at.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  post.body,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.body.copyWith(color: context.at.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A discussion in the list: who, when, the first lines and how many replies.
class _DiscussionRow extends StatelessWidget {
  const _DiscussionRow({required this.post});

  final PostViewDto post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = post.author;
    final replies = l10n.grpReplies(post.replyCount.toInt());
    return AtCard(
      onTap: () => context.push('/posts/${Uri.encodeComponent(post.id)}'),
      padding: const EdgeInsets.all(14),
      semanticLabel: '${a.displayName}, ${post.body}, $replies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Portrait(name: a.displayName, url: a.avatarUrl, size: 28),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  a.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.meta.copyWith(
                    color: context.at.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (a.verified) ...[
                const SizedBox(width: 4),
                const AtVerifiedTick(size: 14),
              ],
              const SizedBox(width: 8),
              Text(
                shortDate(context, post.createdAt),
                style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AtTextStyles.body.copyWith(color: context.at.longForm),
          ),
          const SizedBox(height: 6),
          Text(
            replies,
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
        ],
      ),
    );
  }
}
