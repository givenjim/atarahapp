import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/providers.dart';
import '../account/account_providers.dart' show savedRepositoryProvider;
import '../account/account_repository.dart' show PageOf;
import 'marketplace_repository.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>(
  (ref) => MarketplaceRepository(api: ref.watch(apiClientProvider)),
);

final marketplaceHomeProvider = FutureProvider.autoDispose<MarketplaceHomeDto>(
  (ref) => ref.watch(marketplaceRepositoryProvider).home(),
);

final marketplaceCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryDto>>(
      (ref) => ref.watch(marketplaceRepositoryProvider).categories(),
    );

final sellerTermsProvider = FutureProvider.autoDispose<SellerTermsDto>(
  (ref) => ref.watch(marketplaceRepositoryProvider).terms(),
);

final listingDetailProvider = FutureProvider.autoDispose
    .family<ListingDto, String>(
      (ref, id) => ref.watch(marketplaceRepositoryProvider).listing(id),
    );

final listingReviewsProvider = FutureProvider.autoDispose
    .family<List<ListingReviewDto>, String>(
      (ref, id) => ref.watch(marketplaceRepositoryProvider).reviews(id),
    );

final sellerProfileProvider = FutureProvider.autoDispose
    .family<SellerProfileDto, String>(
      (ref, id) => ref.watch(marketplaceRepositoryProvider).seller(id),
    );

final popularSellersProvider = FutureProvider.autoDispose
    .family<PageOf<SellerCardDto>, String?>(
      (ref, q) => ref.watch(marketplaceRepositoryProvider).sellers(q: q),
    );

final myListingsProvider = FutureProvider.autoDispose<MyListingsDto>(
  (ref) => ref.watch(marketplaceRepositoryProvider).mine(),
);

final myListingProvider = FutureProvider.autoDispose
    .family<MyListingDto, String>(
      (ref, id) => ref.watch(marketplaceRepositoryProvider).myListing(id),
    );

/// The requests the member sent (buyer) or received on their listings (seller).
final enquiriesProvider = FutureProvider.autoDispose
    .family<PageOf<EnquiryDto>, AsEnum>(
      (ref, side) =>
          ref.watch(marketplaceRepositoryProvider).enquiries(side: side),
    );

final enquiryThreadProvider = FutureProvider.autoDispose
    .family<EnquiryThreadDto, String>(
      (ref, id) => ref.watch(marketplaceRepositoryProvider).thread(id),
    );

/// A page at a time of one browse list.
class ListingList {
  const ListingList({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<ListingCardDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  ListingList copyWith({
    List<ListingCardDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => ListingList(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

class ListingListNotifier extends AsyncNotifier<ListingList> {
  ListingListNotifier(this.filters);

  final ListingFilters filters;
  static const _pageSize = 20;

  @override
  Future<ListingList> build() async {
    final first = await ref
        .watch(marketplaceRepositoryProvider)
        .list(filters, limit: _pageSize);
    return ListingList(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(marketplaceRepositoryProvider)
          .list(filters, page: current.page + 1, limit: _pageSize);
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
}

final listingListProvider = AsyncNotifierProvider.autoDispose
    .family<ListingListNotifier, ListingList, ListingFilters>(
      ListingListNotifier.new,
    );

/// Saves flipped on this device, by listing id, so a heart changes at once and stays right across screens.
final listingSavesProvider =
    NotifierProvider<ListingSavesNotifier, Map<String, bool>>(
      ListingSavesNotifier.new,
    );

class ListingSavesNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  /// Flips the save and tells the server; puts it back when the call fails. Returns whether it worked.
  Future<bool> toggle(String id, bool currentlySaved) async {
    final repo = ref.read(savedRepositoryProvider);
    state = {...state, id: !currentlySaved};
    try {
      if (currentlySaved) {
        await repo.unsave(SavedKind.listing, id);
      } else {
        await repo.save(SavedKind.listing, id);
      }
      return true;
    } on Object {
      state = {...state, id: currentlySaved};
      return false;
    }
  }
}
