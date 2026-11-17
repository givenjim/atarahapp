import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/networking/failures.dart';
import '../../../shared/widgets/domain_cards.dart';
import 'groups_common.dart';
import 'groups_providers.dart';

/// The Groups tab of the Community screen: "Your groups", then every group to discover with type filters
/// and search. Fills the space it is given and scrolls on its own.
class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 300) {
        ref.read(discoverGroupsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(groupQueryStateProvider.notifier).setSearch(text);
      }
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(myGroupsProvider);
    ref.invalidate(discoverGroupsProvider);
    try {
      await ref.read(discoverGroupsProvider.future);
    } on Object {
      // The error state on screen explains it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(groupQueryStateProvider);
    final discover = ref.watch(discoverGroupsProvider);
    final overrides = ref.watch(groupMembershipProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: AtTextField(
                  controller: _search,
                  hint: l10n.grpSearchHint,
                  semanticLabel: l10n.grpSearchHint,
                  prefixIcon: LucideIcons.search,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearch,
                  onSubmitted: (t) {
                    _debounce?.cancel();
                    ref.read(groupQueryStateProvider.notifier).setSearch(t);
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _YourGroups()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              22,
              AtSpacing.gutter,
              10,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.grpDiscover,
                style: AtTextStyles.sectionTitle.copyWith(
                  color: context.at.ink,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                  vertical: 4,
                ),
                children: [
                  for (final t in <GroupType?>[
                    null,
                    GroupType.discipline,
                    GroupType.location,
                    GroupType.interest,
                    GroupType.programme,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AtChip(
                        label: t == null
                            ? l10n.grpFilterAll
                            : groupTypeLabel(l10n, t),
                        selected: query.type == t,
                        onTap: () => ref
                            .read(groupQueryStateProvider.notifier)
                            .setType(t),
                      ),
                    ),
                ],
              ),
            ),
          ),
          discover.when(
            loading: () => const SliverPadding(
              padding: EdgeInsets.all(AtSpacing.gutter),
              sliver: SliverToBoxAdapter(child: _ListSkeleton()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AtErrorState(
                  title: l10n.dcLoadFailed,
                  body: e is AppFailure
                      ? e.message
                      : const UnexpectedFailure().message,
                  ctaLabel: l10n.retry,
                  onCta: () => ref.invalidate(discoverGroupsProvider),
                ),
              ),
            ),
            data: (list) => list.items.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AtEmptyState(
                        icon: LucideIcons.users,
                        title: l10n.grpDiscoverEmpty,
                        body: l10n.grpDiscoverEmptyBody,
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AtSpacing.gutter,
                      4,
                      AtSpacing.gutter,
                      28,
                    ),
                    sliver: SliverList.separated(
                      itemCount: list.items.length + (list.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == list.items.length) {
                          return _MoreFooter(list: list);
                        }
                        final g = list.items[i];
                        final o = overrides[g.id];
                        final joined = o?.joined ?? g.joined;
                        final count = o?.memberCount ?? g.memberCount;
                        return GroupCard(
                          name: g.name,
                          typeLabel: groupTypeLabel(l10n, g.type),
                          memberCountLabel: l10n.grpMembers(count.toInt()),
                          icon: groupTypeIcon(g.type),
                          joined: joined,
                          onTap: () => context.push(groupPath(g.slug)),
                          onToggle: () => toggleGroupMembership(
                            context,
                            ref,
                            groupId: g.id,
                            name: g.name,
                            joined: joined,
                            isOwner: g.role == GroupCardDtoRole.owner,
                            memberCount: count,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MoreFooter extends ConsumerWidget {
  const _MoreFooter({required this.list});

  final GroupList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (list.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AtButton(
      label: list.moreFailed ? l10n.retry : l10n.grpLoadMore,
      variant: AtButtonVariant.secondary,
      onPressed: () => ref.read(discoverGroupsProvider.notifier).loadMore(),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: AtSkeleton(height: 80, radius: 18),
        ),
    ],
  );
}

/// The carousel of groups the member is in.
class _YourGroups extends ConsumerWidget {
  const _YourGroups();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mine = ref.watch(myGroupsProvider);
    final overrides = ref.watch(groupMembershipProvider);

    final Widget body = mine.when(
      loading: () => SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            AtSkeleton(width: 200, height: 150, radius: 18),
            SizedBox(width: 12),
            AtSkeleton(width: 200, height: 150, radius: 18),
          ],
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
        child: Row(
          children: [
            Expanded(
              child: Text(
                e is AppFailure ? e.message : const UnexpectedFailure().message,
                style: AtTextStyles.meta.copyWith(color: context.at.muted),
              ),
            ),
            const SizedBox(width: 8),
            AtButton(
              label: l10n.retry,
              size: AtButtonSize.sm,
              fullWidth: false,
              variant: AtButtonVariant.secondary,
              onPressed: () => ref.invalidate(myGroupsProvider),
            ),
          ],
        ),
      ),
      data: (groups) {
        // A group left a moment ago drops out at once; one just joined appears after the server confirms.
        final shown = [
          for (final g in groups)
            if (overrides[g.id]?.joined ?? true) g,
        ];
        if (shown.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
            child: Text(
              l10n.grpYourGroupsEmpty,
              style: AtTextStyles.meta.copyWith(color: context.at.muted),
            ),
          );
        }
        return SizedBox(
          height: 158,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _MineCard(group: shown[i]),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            12,
            AtSpacing.gutter,
            10,
          ),
          child: Text(
            l10n.grpYourGroups,
            style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
          ),
        ),
        body,
      ],
    );
  }
}

class _MineCard extends StatelessWidget {
  const _MineCard({required this.group});

  final GroupCardDto group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = l10n.grpMembers(group.memberCount.toInt());
    return SizedBox(
      width: 200,
      child: AtCard(
        onTap: () => context.push(groupPath(group.slug)),
        padding: EdgeInsets.zero,
        semanticLabel: '${group.name}, $members',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: AtRadii.cardLg.topLeft,
                ),
                child: GroupCover(url: group.coverUrl, type: group.type),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    members,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
