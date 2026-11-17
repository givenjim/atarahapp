import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/networking/failures.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../discover/discover_common.dart';
import 'people_providers.dart';
import 'people_tab.dart';
import 'people_widgets.dart';

void _back(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.community);
  }
}

/// `/creatives`: "People to meet" as its own screen (the same list as the Community People tab).
class PeopleToMeetScreen extends StatelessWidget {
  const PeopleToMeetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(onBack: () => _back(context)),
            Expanded(
              child: PeopleBody(
                header: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    0,
                    AtSpacing.gutter,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.peopleTitle,
                          style: AtTextStyles.tabTitle.copyWith(
                            color: context.at.ink,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.peopleBody,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.body,
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

/// Which of the three connection lists is showing.
enum ConnectionsView {
  connected(ListState.connected),
  received(ListState.pendingReceived),
  sent(ListState.pendingSent);

  const ConnectionsView(this.listState);
  final ListState listState;

  static ConnectionsView parse(String? raw) => values.firstWhere(
    (v) => v.name == raw,
    orElse: () => ConnectionsView.connected,
  );
}

/// `/connections?list=connected|received|sent`: accepted connections, requests to answer and requests sent.
class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({
    super.key,
    this.initial = ConnectionsView.connected,
  });

  final ConnectionsView initial;

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  late ConnectionsView _view = widget.initial;
  final _scroll = ScrollController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(connectionsProvider(_view.listState).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _run(Future<AppFailure?> Function() action) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final failure = await action();
    if (!mounted) return;
    if (failure == null) {
      ref.read(analyticsProvider).track('connection_action');
    } else {
      setState(() => _error = peopleFailureMessage(l10n, failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = connectionsProvider(_view.listState);
    final list = ref.watch(provider);
    final incoming = ref.watch(incomingRequestCountProvider).value ?? 0;
    final notifier = ref.read(provider.notifier);

    String viewLabel(ConnectionsView v) => switch (v) {
      ConnectionsView.connected => l10n.peopleListConnected,
      ConnectionsView.received =>
        incoming > 0
            ? '${l10n.peopleListReceived} ($incoming)'
            : l10n.peopleListReceived,
      ConnectionsView.sent => l10n.peopleListSent,
    };

    (String, String) empty() => switch (_view) {
      ConnectionsView.connected => (
        l10n.peopleConnectedEmptyTitle,
        l10n.peopleConnectedEmptyBody,
      ),
      ConnectionsView.received => (
        l10n.peopleReceivedEmptyTitle,
        l10n.peopleReceivedEmptyBody,
      ),
      ConnectionsView.sent => (
        l10n.peopleSentEmptyTitle,
        l10n.peopleSentEmptyBody,
      ),
    };

    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              title: l10n.peopleConnections,
              onBack: () => _back(context),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                ),
                children: [
                  for (final v in ConnectionsView.values) ...[
                    AtChip(
                      label: viewLabel(v),
                      selected: _view == v,
                      onTap: () => setState(() {
                        _view = v;
                        _error = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(incomingRequestCountProvider);
                  ref.invalidate(provider);
                  try {
                    await ref.read(provider.future);
                  } on Object {
                    // The list shows its own error.
                  }
                },
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    12,
                    AtSpacing.gutter,
                    32,
                  ),
                  children: [
                    if (_error != null) ...[
                      AtInlineBanner(message: _error!),
                      const SizedBox(height: 12),
                    ],
                    PagedSection<ConnectionListItemDto>(
                      async: list,
                      skeletonHeight: 96,
                      retry: () => ref.invalidate(provider),
                      loadMore: notifier.loadMore,
                      empty: () {
                        final (title, body) = empty();
                        return AtEmptyState(
                          icon: LucideIcons.users,
                          title: title,
                          body: body,
                        );
                      },
                      item: (c) => _ConnectionTile(
                        item: c,
                        view: _view,
                        onAccept: () => _run(() => notifier.accept(c.id)),
                        onDecline: () => _run(() => notifier.decline(c.id)),
                        onCancel: () => _run(() => notifier.cancel(c.id)),
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

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.item,
    required this.view,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final ConnectionListItemDto item;
  final ConnectionsView view;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = item.person;
    final date = shortDate(context, item.since.toLocal());
    final actions = switch (view) {
      ConnectionsView.received => Row(
        children: [
          Expanded(
            child: AtButton(
              label: l10n.cpAccept,
              size: AtButtonSize.sm,
              semanticLabel: l10n.peopleAcceptLabel(p.displayName),
              onPressed: onAccept,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AtButton(
              label: l10n.cpDecline,
              variant: AtButtonVariant.secondary,
              size: AtButtonSize.sm,
              semanticLabel: l10n.peopleDeclineLabel(p.displayName),
              onPressed: onDecline,
            ),
          ),
        ],
      ),
      ConnectionsView.sent => Align(
        alignment: Alignment.centerLeft,
        child: AtButton(
          label: l10n.cpCancelRequest,
          variant: AtButtonVariant.secondary,
          size: AtButtonSize.sm,
          fullWidth: false,
          semanticLabel: l10n.peopleSentCancelLabel(p.displayName),
          onPressed: onCancel,
        ),
      ),
      ConnectionsView.connected => null,
    };
    return PersonRowTile(
      name: p.displayName,
      avatarUrl: p.avatarUrl,
      subtitle: p.headline ?? p.discipline,
      detail: switch (view) {
        ConnectionsView.connected => l10n.peopleSince(date),
        _ => l10n.peopleRequestedOn(date),
      },
      actions: actions,
      onTap: () => context.push(Routes.creativePath(p.handle)),
    );
  }
}

/// `/blocked`: people the member has blocked, with Unblock.
class BlockedScreen extends ConsumerStatefulWidget {
  const BlockedScreen({super.key});

  @override
  ConsumerState<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends ConsumerState<BlockedScreen> {
  final _scroll = ScrollController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(blockedProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _unblock(String userId) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final failure = await ref.read(blockedProvider.notifier).unblock(userId);
    if (!mounted || failure == null) return;
    setState(() => _error = peopleFailureMessage(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(blockedProvider);
    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(title: l10n.peopleBlocked, onBack: () => _back(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(blockedProvider);
                  try {
                    await ref.read(blockedProvider.future);
                  } on Object {
                    // The list shows its own error.
                  }
                },
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    4,
                    AtSpacing.gutter,
                    32,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.peopleBlockedBody,
                        style: AtTextStyles.bodySm.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      AtInlineBanner(message: _error!),
                      const SizedBox(height: 12),
                    ],
                    PagedSection<BlockedMemberDto>(
                      async: list,
                      skeletonHeight: 72,
                      retry: () => ref.invalidate(blockedProvider),
                      loadMore: ref.read(blockedProvider.notifier).loadMore,
                      empty: () => AtEmptyState(
                        icon: LucideIcons.userX,
                        title: l10n.peopleBlockedEmptyTitle,
                        body: l10n.peopleBlockedEmptyBody,
                      ),
                      item: (b) => AtCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Portrait(
                              name: b.displayName,
                              url: b.avatarUrl,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AtTextStyles.cardTitle.copyWith(
                                      color: context.at.ink,
                                    ),
                                  ),
                                  Text(
                                    l10n.peopleBlockedSince(
                                      shortDate(context, b.blockedAt.toLocal()),
                                    ),
                                    style: AtTextStyles.metaSm.copyWith(
                                      color: context.at.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AtButton(
                              label: l10n.peopleUnblock,
                              variant: AtButtonVariant.secondary,
                              size: AtButtonSize.sm,
                              fullWidth: false,
                              semanticLabel: l10n.peopleUnblockLabel(
                                b.displayName,
                              ),
                              onPressed: () => _unblock(b.userId),
                            ),
                          ],
                        ),
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
