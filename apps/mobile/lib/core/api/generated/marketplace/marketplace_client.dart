// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/as_enum.dart';
import '../models/create_enquiry_dto.dart';
import '../models/create_listing_dto.dart';
import '../models/enquiry_status.dart';
import '../models/get_api_v1_marketplace_categories_response.dart';
import '../models/get_api_v1_marketplace_enquiries_id_response.dart';
import '../models/get_api_v1_marketplace_enquiries_response.dart';
import '../models/get_api_v1_marketplace_home_response.dart';
import '../models/get_api_v1_marketplace_listings_id_response.dart';
import '../models/get_api_v1_marketplace_listings_id_reviews_response.dart';
import '../models/get_api_v1_marketplace_listings_response.dart';
import '../models/get_api_v1_marketplace_seller_terms_response.dart';
import '../models/get_api_v1_marketplace_sellers_id_response.dart';
import '../models/get_api_v1_marketplace_sellers_response.dart';
import '../models/get_api_v1_me_listings_id_response.dart';
import '../models/get_api_v1_me_listings_response.dart';
import '../models/listing_fields_dto.dart';
import '../models/listing_sort.dart';
import '../models/listing_type.dart';
import '../models/patch_api_v1_me_listings_id_response.dart';
import '../models/post_api_v1_marketplace_enquiries_id_close_response.dart';
import '../models/post_api_v1_marketplace_enquiries_id_messages_response.dart';
import '../models/post_api_v1_marketplace_enquiries_id_review_response.dart';
import '../models/post_api_v1_marketplace_listings_id_enquiries_response.dart';
import '../models/post_api_v1_me_listings_id_archive_response.dart';
import '../models/post_api_v1_me_listings_id_restore_response.dart';
import '../models/post_api_v1_me_listings_id_submit_response.dart';
import '../models/post_api_v1_me_listings_id_withdraw_response.dart';
import '../models/post_api_v1_me_listings_response.dart';
import '../models/post_api_v1_me_services_id_listing_response.dart';
import '../models/publish_service_dto.dart';
import '../models/report_listing_dto.dart';
import '../models/review_dto.dart';
import '../models/send_enquiry_message_dto.dart';
import '../models/sort3.dart';

part 'marketplace_client.g.dart';

@RestApi()
abstract class MarketplaceClient {
  factory MarketplaceClient(Dio dio, {String? baseUrl}) = _MarketplaceClient;

  @GET('/api/v1/marketplace/home')
  Future<GetApiV1MarketplaceHomeResponse> home();

  @GET('/api/v1/marketplace/categories')
  Future<GetApiV1MarketplaceCategoriesResponse> categories();

  @GET('/api/v1/marketplace/seller-terms')
  Future<GetApiV1MarketplaceSellerTermsResponse> terms();

  /// [minPrice] - Whole shillings; listings from this price up.
  ///
  /// [maxPrice] - Whole shillings; listings whose lowest price is at most this.
  ///
  /// [remote] - Only remote listings.
  ///
  /// [priced] - Only listings with a price (not "on request").
  @GET('/api/v1/marketplace/listings')
  Future<GetApiV1MarketplaceListingsResponse> listings({
    @Query('type') ListingType? type,
    @Query('categoryId') String? categoryId,
    @Query('sellerId') String? sellerId,
    @Query('q') String? q,
    @Query('sort') ListingSort? sort,
    @Query('minPrice') num? minPrice,
    @Query('maxPrice') num? maxPrice,
    @Query('remote') bool? remote,
    @Query('priced') bool? priced,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/marketplace/listings/{id}')
  Future<GetApiV1MarketplaceListingsIdResponse> listing({
    @Path('id') required String id,
  });

  @GET('/api/v1/marketplace/listings/{id}/reviews')
  Future<GetApiV1MarketplaceListingsIdReviewsResponse> reviews({
    @Path('id') required String id,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/marketplace/listings/{id}/report')
  Future<void> report({
    @Path('id') required String id,
    @Body() required ReportListingDto body,
  });

  @POST('/api/v1/marketplace/listings/{id}/enquiries')
  Future<PostApiV1MarketplaceListingsIdEnquiriesResponse> requestBooking({
    @Path('id') required String id,
    @Body() required CreateEnquiryDto body,
  });

  @GET('/api/v1/marketplace/sellers')
  Future<GetApiV1MarketplaceSellersResponse> sellers({
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('sort') Sort3? sort = Sort3.popular,
  });

  @GET('/api/v1/marketplace/sellers/{id}')
  Future<GetApiV1MarketplaceSellersIdResponse> seller({
    @Path('id') required String id,
  });

  /// [as] - Requests you sent, or requests on your listings.
  ///
  /// [listingId] - Only requests on this listing.
  @GET('/api/v1/marketplace/enquiries')
  Future<GetApiV1MarketplaceEnquiriesResponse> myEnquiries({
    @Query('as') AsEnum? asEnum,
    @Query('status') EnquiryStatus? status,
    @Query('listingId') String? listingId,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/marketplace/enquiries/{id}')
  Future<GetApiV1MarketplaceEnquiriesIdResponse> thread({
    @Path('id') required String id,
  });

  @POST('/api/v1/marketplace/enquiries/{id}/messages')
  Future<PostApiV1MarketplaceEnquiriesIdMessagesResponse> send({
    @Path('id') required String id,
    @Body() required SendEnquiryMessageDto body,
  });

  @POST('/api/v1/marketplace/enquiries/{id}/close')
  Future<PostApiV1MarketplaceEnquiriesIdCloseResponse> close({
    @Path('id') required String id,
  });

  @POST('/api/v1/marketplace/enquiries/{id}/review')
  Future<PostApiV1MarketplaceEnquiriesIdReviewResponse> review({
    @Path('id') required String id,
    @Body() required ReviewDto body,
  });

  @GET('/api/v1/me/listings')
  Future<GetApiV1MeListingsResponse> mine();

  @POST('/api/v1/me/listings')
  Future<PostApiV1MeListingsResponse> create({
    @Body() required CreateListingDto body,
  });

  @GET('/api/v1/me/listings/{id}')
  Future<GetApiV1MeListingsIdResponse> detail({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/me/listings/{id}')
  Future<PatchApiV1MeListingsIdResponse> update({
    @Path('id') required String id,
    @Body() required ListingFieldsDto body,
  });

  @DELETE('/api/v1/me/listings/{id}')
  Future<void> remove({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/listings/{id}/submit')
  Future<PostApiV1MeListingsIdSubmitResponse> submit({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/listings/{id}/withdraw')
  Future<PostApiV1MeListingsIdWithdrawResponse> withdraw({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/listings/{id}/archive')
  Future<PostApiV1MeListingsIdArchiveResponse> archive({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/listings/{id}/restore')
  Future<PostApiV1MeListingsIdRestoreResponse> restore({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/services/{id}/listing')
  Future<PostApiV1MeServicesIdListingResponse> fromService({
    @Path('id') required String id,
    @Body() required PublishServiceDto body,
  });
}
