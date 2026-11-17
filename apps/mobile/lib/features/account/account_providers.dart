import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/providers.dart';
import '../discover/unread_notifications.dart';
import 'account_repository.dart';

// ---- repositories (tests replace these with in-memory fakes) --------------------------------------------------

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(api: ref.watch(apiClientProvider)),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final dio = ref.watch(apiDioProvider);
  return NotificationsRepository(
    api: ref.watch(apiClientProvider),
    readAllUntyped: () async {
      await dio.post<void>(
        '/api/v1/notifications/read-all',
        data: <String, Object?>{},
      );
    },
  );
});

final savedRepositoryProvider = Provider<SavedRepository>(
  (ref) => SavedRepository(api: ref.watch(apiClientProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(api: ref.watch(apiClientProvider)),
);

final helpRepositoryProvider = Provider<HelpRepository>(
  (ref) => HelpRepository(api: ref.watch(apiClientProvider)),
);

// ---- simple reads ---------------------------------------------------------------------------------------------

final activityHubProvider = FutureProvider.autoDispose<ActivityDto>(
  (ref) => ref.watch(activityRepositoryProvider).hub(),
);

final savedCountsProvider = FutureProvider.autoDispose<SavedCountsDto>(
  (ref) => ref.watch(savedRepositoryProvider).counts(),
);

final accountProvider = FutureProvider.autoDispose<AccountDto>(
  (ref) => ref.watch(accountRepositoryProvider).account(),
);

final privacyProvider = FutureProvider.autoDispose<PrivacyDto>(
  (ref) => ref.watch(accountRepositoryProvider).privacy(),
);

final securityProvider = FutureProvider.autoDispose<SecurityDto>(
  (ref) => ref.watch(accountRepositoryProvider).security(),
);

final sessionsProvider = FutureProvider.autoDispose<List<SessionViewDto>>(
  (ref) => ref.watch(accountRepositoryProvider).sessions(),
);

final exportStateProvider = FutureProvider.autoDispose<ExportStateDto>(
  (ref) => ref.watch(accountRepositoryProvider).exportState(),
);

final membershipProvider = FutureProvider.autoDispose<MembershipViewDto>(
  (ref) => ref.watch(accountRepositoryProvider).membership(),
);

final helpSearchProvider = FutureProvider.autoDispose
    .family<HelpResultDto, String>(
      (ref, q) => ref.watch(helpRepositoryProvider).search(q),
    );

final helpArticleProvider = FutureProvider.autoDispose
    .family<HelpArticleDto, String>(
      (ref, slug) => ref.watch(helpRepositoryProvider).article(slug),
    );

final helpContactProvider = FutureProvider.autoDispose<HelpContactDto>(
  (ref) => ref.watch(helpRepositoryProvider).contact(),
);

final legalListProvider = FutureProvider.autoDispose<List<LegalSummaryDto>>(
  (ref) => ref.watch(helpRepositoryProvider).legalList(),
);

final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalFullDto, String>(
      (ref, type) => ref.watch(helpRepositoryProvider).legalDocument(type),
    );

final notificationPreferencesProvider =
    FutureProvider.autoDispose<List<PreferenceDto>>(
      (ref) => ref.watch(notificationsRepositoryProvider).preferences(),
    );

// ---- notifications list ---------------------------------------------------------------------------------------

/// The notifications the screen shows, for one category chip (null is "All").
class NotificationsView {
  const NotificationsView({
    this.category,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final NotificationCategory? category;
  final List<NotificationItemDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  NotificationsView copyWith({
    List<NotificationItemDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => NotificationsView(
    category: category,
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

class NotificationsController extends AsyncNotifier<NotificationsView> {
  static const _pageSize = 20;

  @override
  Future<NotificationsView> build() => _load(null);

  Future<NotificationsView> _load(NotificationCategory? category) async {
    final page = await ref
        .read(notificationsRepositoryProvider)
        .list(category: category, limit: _pageSize);
    return NotificationsView(
      category: category,
      items: page.items,
      total: page.total,
    );
  }

  Future<void> select(NotificationCategory? category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(category));
  }

  Future<void> refresh() async {
    final category = state.value?.category;
    state = await AsyncValue.guard(() => _load(category));
    unawaited(_syncUnread());
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(notificationsRepositoryProvider)
          .list(
            category: current.category,
            page: current.page + 1,
            limit: _pageSize,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  /// Opening a notification marks it read. The row changes at once; a failure is quiet (it stays unread on the
  /// server and the next refresh shows that).
  Future<void> markRead(NotificationItemDto item) async {
    final current = state.value;
    if (current == null || item.read) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final n in current.items) n.id == item.id ? _asRead(n) : n,
        ],
      ),
    );
    ref.read(unreadNotificationsProvider.notifier).decrement();
    try {
      await ref.read(notificationsRepositoryProvider).markRead(item.id);
    } on Object {
      // The count is re-read from the server the next time the list refreshes.
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    final category = current.category;
    final before = current;
    state = AsyncData(
      current.copyWith(items: [for (final n in current.items) _asRead(n)]),
    );
    try {
      await ref
          .read(notificationsRepositoryProvider)
          .readAll(category: category);
      await _syncUnread();
    } on Object {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> _syncUnread() async {
    try {
      final count = await ref
          .read(notificationsRepositoryProvider)
          .unreadCount();
      ref.read(unreadNotificationsProvider.notifier).set(count.unread.toInt());
    } on Object {
      // Keep the count we have.
    }
  }

  static NotificationItemDto _asRead(NotificationItemDto n) =>
      NotificationItemDto(
        id: n.id,
        category: n.category,
        type: n.type,
        title: n.title,
        body: n.body,
        deepLink: n.deepLink,
        data: n.data,
        read: true,
        createdAt: n.createdAt,
        group: n.group,
      );
}

final notificationsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      NotificationsView
    >(NotificationsController.new);

/// Per-category unread counts for the chips (null while loading; the chips then show no numbers).
final unreadByCategoryProvider = FutureProvider.autoDispose<UnreadCountDto>(
  (ref) => ref.watch(notificationsRepositoryProvider).unreadCount(),
);

// ---- saved list -----------------------------------------------------------------------------------------------

class SavedView {
  const SavedView({
    this.type,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final SavedKind? type;
  final List<SavedItemDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  SavedView copyWith({
    List<SavedItemDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => SavedView(
    type: type,
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

class SavedController extends AsyncNotifier<SavedView> {
  static const _pageSize = 20;

  @override
  Future<SavedView> build() => _load(null);

  Future<SavedView> _load(SavedKind? type) async {
    final page = await ref
        .read(savedRepositoryProvider)
        .list(type: type, limit: _pageSize);
    return SavedView(type: type, items: page.items, total: page.total);
  }

  Future<void> select(SavedKind? type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(type));
  }

  Future<void> refresh() async {
    final type = state.value?.type;
    state = await AsyncValue.guard(() => _load(type));
    ref.invalidate(savedCountsProvider);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(savedRepositoryProvider)
          .list(type: current.type, page: current.page + 1, limit: _pageSize);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  /// Un-saves from the row. The row goes at once and comes back if the server says no (the caller shows why).
  Future<void> unsave(SavedItemDto item) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final s in current.items)
            if (!(s.type == item.type && s.targetId == item.targetId)) s,
        ],
        total: current.total - 1,
      ),
    );
    try {
      await ref.read(savedRepositoryProvider).unsave(item.type, item.targetId);
      ref.invalidate(savedCountsProvider);
    } on Object {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final savedControllerProvider =
    AsyncNotifierProvider.autoDispose<SavedController, SavedView>(
      SavedController.new,
    );

// ---- applications list ----------------------------------------------------------------------------------------

class ApplicationsView {
  const ApplicationsView({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<ApplicationItemDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;
}

class ApplicationsController extends AsyncNotifier<ApplicationsView> {
  static const _pageSize = 20;

  @override
  Future<ApplicationsView> build() async {
    final page = await ref
        .read(activityRepositoryProvider)
        .applications(limit: _pageSize);
    return ApplicationsView(items: page.items, total: page.total);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(build);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(
      ApplicationsView(
        items: current.items,
        total: current.total,
        page: current.page,
        loadingMore: true,
      ),
    );
    try {
      final next = await ref
          .read(activityRepositoryProvider)
          .applications(page: current.page + 1, limit: _pageSize);
      state = AsyncData(
        ApplicationsView(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
        ),
      );
    } on Object {
      state = AsyncData(
        ApplicationsView(
          items: current.items,
          total: current.total,
          page: current.page,
          moreFailed: true,
        ),
      );
    }
  }
}

final applicationsControllerProvider =
    AsyncNotifierProvider.autoDispose<ApplicationsController, ApplicationsView>(
      ApplicationsController.new,
    );
