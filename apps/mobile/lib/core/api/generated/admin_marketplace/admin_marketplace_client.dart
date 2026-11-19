// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/feature_listing_dto.dart';
import '../models/get_api_v1_admin_marketplace_categories_response.dart';
import '../models/get_api_v1_admin_marketplace_listings_id_response.dart';
import '../models/get_api_v1_admin_marketplace_listings_response.dart';
import '../models/get_api_v1_admin_marketplace_reports_response.dart';
import '../models/get_api_v1_admin_marketplace_reviews_response.dart';
import '../models/get_api_v1_admin_marketplace_sellers_id_response.dart';
import '../models/get_api_v1_admin_marketplace_sellers_response.dart';
import '../models/listing_report_status.dart';
import '../models/listing_status.dart';
import '../models/marketplace_category_fields_dto.dart';
import '../models/patch_api_v1_admin_marketplace_categories_id_response.dart';
import '../models/patch_api_v1_admin_marketplace_sellers_id_direct_publish_response.dart';
import '../models/post_api_v1_admin_marketplace_categories_response.dart';
import '../models/post_api_v1_admin_marketplace_listings_id_approve_response.dart';
import '../models/post_api_v1_admin_marketplace_listings_id_feature_response.dart';
import '../models/post_api_v1_admin_marketplace_listings_id_reinstate_response.dart';
import '../models/post_api_v1_admin_marketplace_listings_id_reject_response.dart';
import '../models/post_api_v1_admin_marketplace_listings_id_suspend_response.dart';
import '../models/post_api_v1_admin_marketplace_reports_id_resolve_response.dart';
import '../models/post_api_v1_admin_marketplace_reviews_id_hide_response.dart';
import '../models/post_api_v1_admin_marketplace_reviews_id_restore_response.dart';
import '../models/post_api_v1_admin_marketplace_sellers_id_reinstate_response.dart';
import '../models/post_api_v1_admin_marketplace_sellers_id_suspend_response.dart';
import '../models/reason_dto.dart';
import '../models/resolve_report_dto.dart';
import '../models/review_visibility.dart';
import '../models/seller_status.dart';
import '../models/set_direct_publish_dto.dart';
import '../models/update_marketplace_category_dto.dart';

part 'admin_marketplace_client.g.dart';

@RestApi()
abstract class AdminMarketplaceClient {
  factory AdminMarketplaceClient(Dio dio, {String? baseUrl}) = _AdminMarketplaceClient;

  /// [q] - Name, handle or email.
  @GET('/api/v1/admin/marketplace/sellers')
  Future<GetApiV1AdminMarketplaceSellersResponse> sellers({
    @Query('q') String? q,
    @Query('status') SellerStatus? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/marketplace/sellers/{id}')
  Future<GetApiV1AdminMarketplaceSellersIdResponse> seller({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/marketplace/sellers/{id}/suspend')
  Future<PostApiV1AdminMarketplaceSellersIdSuspendResponse> suspendSeller({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @POST('/api/v1/admin/marketplace/sellers/{id}/reinstate')
  Future<PostApiV1AdminMarketplaceSellersIdReinstateResponse> reinstateSeller({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @PATCH('/api/v1/admin/marketplace/sellers/{id}/direct-publish')
  Future<PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse> directPublish({
    @Path('id') required String id,
    @Body() required SetDirectPublishDto body,
  });

  /// [reported] - Only listings with open reports.
  @GET('/api/v1/admin/marketplace/listings')
  Future<GetApiV1AdminMarketplaceListingsResponse> listings({
    @Query('status') ListingStatus? status,
    @Query('q') String? q,
    @Query('reported') bool? reported,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/marketplace/listings/{id}')
  Future<GetApiV1AdminMarketplaceListingsIdResponse> listing({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/marketplace/listings/{id}/approve')
  Future<PostApiV1AdminMarketplaceListingsIdApproveResponse> approve({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/marketplace/listings/{id}/reject')
  Future<PostApiV1AdminMarketplaceListingsIdRejectResponse> reject({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @POST('/api/v1/admin/marketplace/listings/{id}/suspend')
  Future<PostApiV1AdminMarketplaceListingsIdSuspendResponse> suspend({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @POST('/api/v1/admin/marketplace/listings/{id}/reinstate')
  Future<PostApiV1AdminMarketplaceListingsIdReinstateResponse> reinstate({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @POST('/api/v1/admin/marketplace/listings/{id}/feature')
  Future<PostApiV1AdminMarketplaceListingsIdFeatureResponse> feature({
    @Path('id') required String id,
    @Body() required FeatureListingDto body,
  });

  @GET('/api/v1/admin/marketplace/reports')
  Future<GetApiV1AdminMarketplaceReportsResponse> reports({
    @Query('status') ListingReportStatus? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/marketplace/reports/{id}/resolve')
  Future<PostApiV1AdminMarketplaceReportsIdResolveResponse> resolveReport({
    @Path('id') required String id,
    @Body() required ResolveReportDto body,
  });

  @GET('/api/v1/admin/marketplace/categories')
  Future<GetApiV1AdminMarketplaceCategoriesResponse> categories();

  @POST('/api/v1/admin/marketplace/categories')
  Future<PostApiV1AdminMarketplaceCategoriesResponse> createCategory({
    @Body() required MarketplaceCategoryFieldsDto body,
  });

  @PATCH('/api/v1/admin/marketplace/categories/{id}')
  Future<PatchApiV1AdminMarketplaceCategoriesIdResponse> updateCategory({
    @Path('id') required String id,
    @Body() required UpdateMarketplaceCategoryDto body,
  });

  @GET('/api/v1/admin/marketplace/reviews')
  Future<GetApiV1AdminMarketplaceReviewsResponse> reviews({
    @Query('status') ReviewVisibility? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/marketplace/reviews/{id}/hide')
  Future<PostApiV1AdminMarketplaceReviewsIdHideResponse> hideReview({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });

  @POST('/api/v1/admin/marketplace/reviews/{id}/restore')
  Future<PostApiV1AdminMarketplaceReviewsIdRestoreResponse> restoreReview({
    @Path('id') required String id,
    @Body() required ReasonDto body,
  });
}
