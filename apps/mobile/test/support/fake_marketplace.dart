import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/features/account/account_repository.dart' show PageOf;
import 'package:atarah/features/marketplace/marketplace_repository.dart';

SellerCardDto sellerCard({
  String id = 'sel-1',
  String name = 'Amina Otieno',
  bool verified = false,
  num? rating,
}) => SellerCardDto(
  id: id,
  displayName: name,
  handle: 'amina',
  headline: 'Wedding photographer',
  ratingAverage: rating,
  ratingCount: rating == null ? 0 : 3,
  completedCount: 2,
  listingCount: 1,
  verified: verified,
);

ListingCardDto listingCard({
  String id = 'l-1',
  String title = 'Wedding photography',
  ListingStatus status = ListingStatus.published,
  ListingType type = ListingType.service,
  bool saved = false,
}) => ListingCardDto(
  id: id,
  type: type,
  title: title,
  categoryName: 'Photo',
  pricingType: PricingType.fixed,
  priceLabel: 'KES 25,000',
  fromLabel: 'From KES 25,000',
  seller: sellerCard(),
  ratingCount: 0,
  featured: false,
  saved: saved,
  status: status,
);

ListingDto listingDetail({
  String id = 'l-1',
  String title = 'Wedding photography',
  String? openEnquiryId,
  bool isOwner = false,
}) => ListingDto(
  id: id,
  type: ListingType.service,
  title: title,
  categoryName: 'Photo',
  pricingType: PricingType.fixed,
  priceLabel: 'KES 25,000',
  fromLabel: 'From KES 25,000',
  seller: sellerCard(),
  ratingCount: 0,
  featured: false,
  saved: false,
  status: ListingStatus.published,
  description: 'A full day of coverage with an edited gallery.',
  includedItems: const ['Edited gallery', 'Print rights'],
  deliveryDays: 14,
  workMode: WorkMode.remote,
  locationLabel: 'Remote',
  audienceText: 'Couples and families',
  categoryId: 'c-1',
  media: const [],
  portfolio: const [],
  reviews: const [],
  isOwner: isOwner,
  openEnquiryId: openEnquiryId,
  requestNote: "You'll agree details and payment directly with the seller.",
  shareUrl: 'https://atarah.app/marketplace/listings/$id',
);

CategoryDto category({String id = 'c-1', String name = 'Photo'}) =>
    CategoryDto(
      id: id,
      slug: name.toLowerCase(),
      name: name,
      icon: 'camera',
      tone: 'violet',
      count: 1,
    );

/// In-memory marketplace for widget tests.
class FakeMarketplaceRepository implements MarketplaceRepository {
  FakeMarketplaceRepository({
    this.isSeller = false,
    List<ListingCardDto>? listings,
    List<CategoryDto>? cats,
  }) : listings = listings ?? [listingCard()],
       _categories = cats ?? [category()];

  bool isSeller;
  final List<ListingCardDto> listings;
  final List<CategoryDto> _categories;
  ListingDto detail = listingDetail();
  SellerTermsDto termsDto = const SellerTermsDto(
    version: 'draft-1',
    isDraft: true,
    title: 'Seller terms (draft)',
    body: 'DRAFT PLACEHOLDER terms.',
  );

  /// What the app sent.
  final List<({String listingId, String message})> requests = [];
  final List<String> created = [];
  final List<String> submitted = [];
  bool? acceptedTerms;

  @override
  Future<MarketplaceHomeDto> home() async => MarketplaceHomeDto(
    isSeller: isSeller,
    categories: _categories,
    featured: const [],
    popularSellers: [sellerCard()],
    recent: listings,
  );

  @override
  Future<List<CategoryDto>> categories() async => _categories;

  @override
  Future<SellerTermsDto> terms() async => termsDto;

  @override
  Future<PageOf<ListingCardDto>> list(
    ListingFilters f, {
    int page = 1,
    int limit = 20,
  }) async => PageOf(listings, listings.length);

  @override
  Future<ListingDto> listing(String id) async => detail;

  @override
  Future<List<ListingReviewDto>> reviews(String id) async => const [];

  @override
  Future<PageOf<SellerCardDto>> sellers({String? q, int page = 1}) async =>
      PageOf([sellerCard()], 1);

  @override
  Future<SellerProfileDto> seller(String id) => throw UnimplementedError();

  @override
  Future<void> report(String id, ReportReason reason, String? note) async {}

  @override
  Future<EnquiryThreadDto> requestBooking(
    String listingId, {
    required String message,
    int? budget,
    String? timing,
  }) async {
    requests.add((listingId: listingId, message: message));
    detail = listingDetail(openEnquiryId: 'e-1');
    return thread0;
  }

  EnquiryThreadDto get thread0 => EnquiryThreadDto(
    id: 'e-1',
    listingId: 'l-1',
    listingTitle: 'Wedding photography',
    status: EnquiryStatus.valueNew,
    role: EnquiryThreadDtoRole.buyer,
    counterpart: const EnquiryPartyDto(userId: 'u-2', displayName: 'Amina'),
    message: 'I need photos for a wedding.',
    unread: false,
    lastMessageAt: DateTime.utc(2026, 11, 18),
    createdAt: DateTime.utc(2026, 11, 18),
    canReview: false,
    canClose: false,
    reviewed: false,
    messages: const [],
  );

  @override
  Future<PageOf<EnquiryDto>> enquiries({AsEnum? side, int page = 1}) async =>
      const PageOf([], 0);

  @override
  Future<EnquiryThreadDto> thread(String id) async => thread0;

  @override
  Future<EnquiryThreadDto> send(String id, String body) async => thread0;

  @override
  Future<EnquiryThreadDto> close(String id) async => thread0;

  @override
  Future<EnquiryThreadDto> review(String id, int rating, String? body) async =>
      thread0;

  @override
  Future<MyListingsDto> mine() async => MyListingsDto(
    isSeller: isSeller,
    stats: const MyListingsStatsDto(live: 0, newInterest: 0, views30d: 0),
    listings: isSeller ? listings : const [],
    sellerStatus: isSeller ? SellerStatus.active : null,
  );

  @override
  Future<MyListingDto> myListing(String id) => throw UnimplementedError();

  @override
  Future<MyListingDto> create(CreateListingDto body) =>
      throw UnimplementedError();

  @override
  Future<MyListingDto> update(String id, ListingFieldsDto body) =>
      throw UnimplementedError();

  @override
  Future<SubmitResultDto> submit(String id) => throw UnimplementedError();

  @override
  Future<MyListingDto> withdraw(String id) => throw UnimplementedError();

  @override
  Future<MyListingDto> archive(String id) => throw UnimplementedError();

  @override
  Future<MyListingDto> restore(String id) => throw UnimplementedError();

  @override
  Future<void> remove(String id) async {}

  @override
  Future<MyListingDto> fromService(
    String serviceId,
    String categoryId, {
    bool? acceptTerms,
    String? termsVersion,
  }) => throw UnimplementedError();
}
