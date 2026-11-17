import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/networking/failures.dart';
import '../../../core/providers.dart';
import '../../profile/profile_providers.dart';
import '../../profile/profile_repository.dart';
import 'people_repository.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => PeopleRepository(api: ref.watch(apiClientProvider)),
);

/// One page-at-a-time list (offset pagination).
class Paged<T> {
  const Paged({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<T> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  Paged<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => Paged(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

const _pageSize = 20;

// ---------------------------------------------------------------- People to meet

/// The filters on People to meet. Kept while the app runs so coming back finds the same list.
class PeopleFiltersController extends Notifier<PeopleFilters> {
  @override
  PeopleFilters build() => const PeopleFilters();

  void set(PeopleFilters next) => state = next;
  void reset() => state = const PeopleFilters();
}

final peopleFiltersProvider =
    NotifierProvider<PeopleFiltersController, PeopleFilters>(
      PeopleFiltersController.new,
    );

/// Where the caller stands with someone in the list.
enum PersonRel { none, requested, connected, incoming }

/// One suggestion with its live connection state.
class PersonRow {
  const PersonRow({
    required this.person,
    required this.rel,
    this.connectionId,
    this.busy = false,
  });

  factory PersonRow.fromDto(PersonToMeetDto d) => PersonRow(
    person: d.person,
    rel: d.connectionState == PersonConnectionState.pendingSent
        ? PersonRel.requested
        : PersonRel.none,
    connectionId: d.connectionId,
  );

  final CreativeCardDto person;
  final PersonRel rel;
  final String? connectionId;
  final bool busy;

  PersonRow copyWith({PersonRel? rel, String? connectionId, bool? busy}) =>
      PersonRow(
        person: person,
        rel: rel ?? this.rel,
        connectionId: connectionId ?? this.connectionId,
        busy: busy ?? this.busy,
      );
}

PersonRel _relOf(ConnectionStateDtoState s) => switch (s) {
  ConnectionStateDtoState.pendingSent => PersonRel.requested,
  ConnectionStateDtoState.connected => PersonRel.connected,
  ConnectionStateDtoState.pendingReceived => PersonRel.incoming,
  _ => PersonRel.none,
};

class PeopleSuggestions extends AsyncNotifier<Paged<PersonRow>> {
  @override
  Future<Paged<PersonRow>> build() async {
    final filters = ref.watch(peopleFiltersProvider);
    final first = await ref
        .watch(peopleRepositoryProvider)
        .suggestions(filters, limit: _pageSize);
    return Paged(
      items: [for (final d in first.items) PersonRow.fromDto(d)],
      total: first.total,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(peopleRepositoryProvider)
          .suggestions(
            ref.read(peopleFiltersProvider),
            page: current.page + 1,
            limit: _pageSize,
          );
      final seen = {for (final r in current.items) r.person.handle};
      state = AsyncData(
        current.copyWith(
          items: [
            ...current.items,
            for (final d in next.items)
              if (!seen.contains(d.person.handle)) PersonRow.fromDto(d),
          ],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  void _patch(String handle, PersonRow Function(PersonRow) f) {
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(
      cur.copyWith(
        items: [
          for (final r in cur.items)
            if (r.person.handle == handle) f(r) else r,
        ],
      ),
    );
  }

  /// Sends a request. The card flips to "Requested" at once; if the server says no it flips back and the
  /// failure is returned so the screen can say why. Returns null on success.
  Future<AppFailure?> connect(String handle) async {
    final before = state.value?.items
        .where((r) => r.person.handle == handle)
        .firstOrNull;
    if (before == null || before.busy || before.rel != PersonRel.none) {
      return null;
    }
    _patch(handle, (r) => r.copyWith(rel: PersonRel.requested, busy: true));
    try {
      final res = await ref.read(profileRepositoryProvider).connect(handle);
      final rel = _relOf(res.state);
      _patch(
        handle,
        (r) => r.copyWith(rel: rel, connectionId: res.id, busy: false),
      );
      ref.invalidate(connectionsProvider(ListState.pendingSent));
      if (rel == PersonRel.connected) {
        ref.invalidate(connectionsProvider(ListState.connected));
      }
      return null;
    } on Object catch (e) {
      _patch(handle, (r) => r.copyWith(rel: before.rel, busy: false));
      return mapError(e);
    }
  }
}

final peopleSuggestionsProvider =
    AsyncNotifierProvider<PeopleSuggestions, Paged<PersonRow>>(
      PeopleSuggestions.new,
    );

// ---------------------------------------------------------------- Connections

class ConnectionsController
    extends AsyncNotifier<Paged<ConnectionListItemDto>> {
  ConnectionsController(this.kind);

  final ListState kind;

  @override
  Future<Paged<ConnectionListItemDto>> build() async {
    final first = await ref
        .watch(peopleRepositoryProvider)
        .connections(kind, limit: _pageSize);
    return Paged(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(peopleRepositoryProvider)
          .connections(kind, page: current.page + 1, limit: _pageSize);
      final seen = {for (final r in current.items) r.id};
      state = AsyncData(
        current.copyWith(
          items: [
            ...current.items,
            for (final i in next.items)
              if (!seen.contains(i.id)) i,
          ],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  /// Takes the row out at once, runs [call], and puts the row back where it was if that fails.
  Future<AppFailure?> _optimisticRemove(
    String id,
    Future<ConnectionStateDto> Function(ProfileRepository) call, {
    required bool acceptedNow,
  }) async {
    final cur = state.value;
    if (cur == null) return null;
    final index = cur.items.indexWhere((i) => i.id == id);
    if (index < 0) return null;
    final row = cur.items[index];
    state = AsyncData(
      cur.copyWith(
        items: [...cur.items]..removeAt(index),
        total: cur.total > 0 ? cur.total - 1 : 0,
      ),
    );
    try {
      await call(ref.read(profileRepositoryProvider));
      ref.invalidate(incomingRequestCountProvider);
      if (acceptedNow) ref.invalidate(connectionsProvider(ListState.connected));
      return null;
    } on Object catch (e) {
      final now = state.value ?? cur;
      final items = [...now.items];
      items.insert(index.clamp(0, items.length), row);
      state = AsyncData(now.copyWith(items: items, total: now.total + 1));
      return mapError(e);
    }
  }

  Future<AppFailure?> accept(String id) =>
      _optimisticRemove(id, (p) => p.accept(id), acceptedNow: true);

  Future<AppFailure?> decline(String id) =>
      _optimisticRemove(id, (p) => p.decline(id), acceptedNow: false);

  /// Withdraws a request the caller sent.
  Future<AppFailure?> cancel(String id) =>
      _optimisticRemove(id, (p) => p.removeConnection(id), acceptedNow: false);
}

final connectionsProvider =
    AsyncNotifierProvider.family<
      ConnectionsController,
      Paged<ConnectionListItemDto>,
      ListState
    >(ConnectionsController.new);

/// How many requests are waiting for the caller. The badge on the People chip and the Requests row.
final incomingRequestCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final page = await ref
      .watch(peopleRepositoryProvider)
      .connections(ListState.pendingReceived, limit: 1);
  return page.total;
});

// ---------------------------------------------------------------- Blocked

class BlockedController extends AsyncNotifier<Paged<BlockedMemberDto>> {
  @override
  Future<Paged<BlockedMemberDto>> build() async {
    final first = await ref
        .watch(peopleRepositoryProvider)
        .blocks(limit: _pageSize);
    return Paged(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(peopleRepositoryProvider)
          .blocks(page: current.page + 1, limit: _pageSize);
      final seen = {for (final r in current.items) r.userId};
      state = AsyncData(
        current.copyWith(
          items: [
            ...current.items,
            for (final b in next.items)
              if (!seen.contains(b.userId)) b,
          ],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  /// Unblocks at once; the row comes back if the server refuses.
  Future<AppFailure?> unblock(String userId) async {
    final cur = state.value;
    if (cur == null) return null;
    final index = cur.items.indexWhere((b) => b.userId == userId);
    if (index < 0) return null;
    final row = cur.items[index];
    state = AsyncData(
      cur.copyWith(
        items: [...cur.items]..removeAt(index),
        total: cur.total > 0 ? cur.total - 1 : 0,
      ),
    );
    try {
      await ref.read(peopleRepositoryProvider).unblock(userId);
      // They may show up in suggestions again.
      ref.invalidate(peopleSuggestionsProvider);
      return null;
    } on Object catch (e) {
      final now = state.value ?? cur;
      final items = [...now.items];
      items.insert(index.clamp(0, items.length), row);
      state = AsyncData(now.copyWith(items: items, total: now.total + 1));
      return mapError(e);
    }
  }
}

final blockedProvider =
    AsyncNotifierProvider<BlockedController, Paged<BlockedMemberDto>>(
      BlockedController.new,
    );
