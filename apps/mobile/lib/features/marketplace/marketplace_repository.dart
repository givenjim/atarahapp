import '../../core/api/generated/export.dart';
import '../account/account_repository.dart' show PageOf, guarded;

/// What narrows the marketplace list. Equal filters are equal values, so a list can be cached per combination.
class ListingFilters {
  const ListingFilters({
    this.type,
    this.categoryId,
    this.categoryName,
    this.q,
    this.sellerId,
    this.sort = ListingSort.recommended,
    this.minPrice,
    this.maxPrice,
    this.remote = false,
  });

  final ListingType? type;
  final String? categoryId;

  /// Only for the screen title; not sent to the API.
  final String? categoryName;
  final String? q;
  final String? sellerId;
  final ListingSort sort;
  final int? minPrice;
  final int? maxPrice;
  final bool remote;

  /// Filters from the sheet (the category and the sort are not filters).
  int get activeCount => [
    type != null,
    minPrice != null || maxPrice != null,
    remote,
  ].where((x) => x).length;

  ListingFilters copyWith({
    Object? type = _keep,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    bool? remote,
    ListingSort? sort,
  }) => ListingFilters(
    type: identical(type, _keep) ? this.type : type as ListingType?,
    categoryId: categoryId,
    categoryName: categoryName,
    q: q,
    sellerId: sellerId,
    sort: sort ?? this.sort,
    minPrice: identical(minPrice, _keep) ? this.minPrice : minPrice as int?,
    maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as int?,
    remote: remote ?? this.remote,
  );

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is ListingFilters &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.q == q &&
      other.sellerId == sellerId &&
      other.sort == sort &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.remote == remote;

  @override
  int get hashCode => Object.hash(
    type,
    categoryId,
    q,
    sellerId,
    sort,
    minPrice,
    maxPrice,
    remote,
  );
}

/// The marketplace: browsing, listings, sellers, the member's own listings and the request threads, with errors
/// mapped to typed failures. Widgets go through providers; tests replace this with an in-memory fake.
class MarketplaceRepository {
  MarketplaceRepository({required this._api});

  final AtarahApiClient _api;

  Future<MarketplaceHomeDto> home() =>
      guarded(() async => (await _api.marketplace.home()).data);

  Future<List<CategoryDto>> categories() =>
      guarded(() async => (await _api.marketplace.categories()).data);

  Future<SellerTermsDto> terms() =>
      guarded(() async => (await _api.marketplace.terms()).data);

  Future<PageOf<ListingCardDto>> list(
    ListingFilters f, {
    int page = 1,
    int limit = 20,
  }) => guarded(() async {
    final res = await _api.marketplace.listings(
      type: f.type,
      categoryId: f.categoryId,
      sellerId: f.sellerId,
      q: f.q,
      sort: f.sort,
      minPrice: f.minPrice,
      maxPrice: f.maxPrice,
      remote: f.remote ? true : null,
      page: page,
      limit: limit,
    );
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<ListingDto> listing(String id) =>
      guarded(() async => (await _api.marketplace.listing(id: id)).data);

  Future<List<ListingReviewDto>> reviews(String id) => guarded(
    () async => (await _api.marketplace.reviews(id: id, limit: 50)).data,
  );

  Future<PageOf<SellerCardDto>> sellers({String? q, int page = 1}) =>
      guarded(() async {
        final res = await _api.marketplace.sellers(q: q, page: page);
        return PageOf(res.data, _total(res.meta, res.data.length));
      });

  Future<SellerProfileDto> seller(String id) =>
      guarded(() async => (await _api.marketplace.seller(id: id)).data);

  Future<void> report(String id, ReportReason reason, String? note) => guarded(
    () => _api.marketplace.report(
      id: id,
      body: ReportListingDto(reason: reason, note: note),
    ),
  );

  Future<EnquiryThreadDto> requestBooking(
    String listingId, {
    required String message,
    int? budget,
    String? timing,
  }) => guarded(
    () async => (await _api.marketplace.requestBooking(
      id: listingId,
      body: CreateEnquiryDto(
        message: message,
        budget: budget,
        preferredTiming: timing,
      ),
    )).data,
  );

  // ---- requests ----

  Future<PageOf<EnquiryDto>> enquiries({AsEnum? side, int page = 1}) => guarded(
    () async {
      final res = await _api.marketplace.myEnquiries(asEnum: side, page: page);
      return PageOf(res.data, _total(res.meta, res.data.length));
    },
  );

  Future<EnquiryThreadDto> thread(String id) =>
      guarded(() async => (await _api.marketplace.thread(id: id)).data);

  Future<EnquiryThreadDto> send(String id, String body) => guarded(
    () async => (await _api.marketplace.send(
      id: id,
      body: SendEnquiryMessageDto(body: body),
    )).data,
  );

  Future<EnquiryThreadDto> close(String id) =>
      guarded(() async => (await _api.marketplace.close(id: id)).data);

  Future<EnquiryThreadDto> review(String id, int rating, String? body) =>
      guarded(
        () async => (await _api.marketplace.review(
          id: id,
          body: ReviewDto(rating: rating, body: body),
        )).data,
      );

  // ---- the member's own listings ----

  Future<MyListingsDto> mine() =>
      guarded(() async => (await _api.marketplace.mine()).data);

  Future<MyListingDto> myListing(String id) =>
      guarded(() async => (await _api.marketplace.detail(id: id)).data);

  Future<MyListingDto> create(CreateListingDto body) =>
      guarded(() async => (await _api.marketplace.create(body: body)).data);

  Future<MyListingDto> update(String id, ListingFieldsDto body) => guarded(
    () async => (await _api.marketplace.update(id: id, body: body)).data,
  );

  Future<SubmitResultDto> submit(String id) =>
      guarded(() async => (await _api.marketplace.submit(id: id)).data);

  Future<MyListingDto> withdraw(String id) =>
      guarded(() async => (await _api.marketplace.withdraw(id: id)).data);

  Future<MyListingDto> archive(String id) =>
      guarded(() async => (await _api.marketplace.archive(id: id)).data);

  Future<MyListingDto> restore(String id) =>
      guarded(() async => (await _api.marketplace.restore(id: id)).data);

  Future<void> remove(String id) =>
      guarded(() => _api.marketplace.remove(id: id));

  Future<MyListingDto> fromService(
    String serviceId,
    String categoryId, {
    bool? acceptTerms,
    String? termsVersion,
  }) => guarded(
    () async => (await _api.marketplace.fromService(
      id: serviceId,
      body: PublishServiceDto(
        categoryId: categoryId,
        acceptTerms: acceptTerms,
        termsVersion: termsVersion,
      ),
    )).data,
  );
}

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}
