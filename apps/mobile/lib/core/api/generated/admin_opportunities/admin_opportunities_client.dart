// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/feature_opportunity_dto.dart';
import '../models/get_api_v1_admin_opportunities_id_response.dart';
import '../models/get_api_v1_admin_opportunities_link_health_response.dart';
import '../models/get_api_v1_admin_opportunities_response.dart';
import '../models/get_api_v1_admin_opportunity_providers_id_response.dart';
import '../models/get_api_v1_admin_opportunity_providers_response.dart';
import '../models/import_csv_dto.dart';
import '../models/opportunity_fields_dto.dart';
import '../models/opportunity_status.dart';
import '../models/opportunity_type.dart';
import '../models/patch_api_v1_admin_opportunities_id_response.dart';
import '../models/patch_api_v1_admin_opportunity_providers_id_response.dart';
import '../models/post_api_v1_admin_opportunities_id_archive_response.dart';
import '../models/post_api_v1_admin_opportunities_id_close_response.dart';
import '../models/post_api_v1_admin_opportunities_id_feature_response.dart';
import '../models/post_api_v1_admin_opportunities_id_publish_response.dart';
import '../models/post_api_v1_admin_opportunities_id_reject_response.dart';
import '../models/post_api_v1_admin_opportunities_id_remove_response.dart';
import '../models/post_api_v1_admin_opportunities_id_set_trust_response.dart';
import '../models/post_api_v1_admin_opportunities_id_verify_response.dart';
import '../models/post_api_v1_admin_opportunities_import_preview_response.dart';
import '../models/post_api_v1_admin_opportunities_import_response.dart';
import '../models/post_api_v1_admin_opportunities_response.dart';
import '../models/post_api_v1_admin_opportunity_providers_id_verify_response.dart';
import '../models/post_api_v1_admin_opportunity_providers_response.dart';
import '../models/provider_fields_dto.dart';
import '../models/reject_opportunity_dto.dart';
import '../models/result.dart';
import '../models/set_trust_dto.dart';
import '../models/update_opportunity_dto.dart';
import '../models/update_provider_dto.dart';
import '../models/verification_status.dart';
import '../models/verify_opportunity_dto.dart';
import '../models/verify_provider_dto.dart';

part 'admin_opportunities_client.g.dart';

@RestApi()
abstract class AdminOpportunitiesClient {
  factory AdminOpportunitiesClient(Dio dio, {String? baseUrl}) =
      _AdminOpportunitiesClient;

  @GET('/api/v1/admin/opportunity-providers')
  Future<GetApiV1AdminOpportunityProvidersResponse> listProviders({
    @Query('q') String? q,
    @Query('verification') VerificationStatus? verification,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/opportunity-providers')
  Future<PostApiV1AdminOpportunityProvidersResponse> createProvider({
    @Body() required ProviderFieldsDto body,
  });

  @GET('/api/v1/admin/opportunity-providers/{id}')
  Future<GetApiV1AdminOpportunityProvidersIdResponse> getProvider({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/opportunity-providers/{id}')
  Future<PatchApiV1AdminOpportunityProvidersIdResponse> updateProvider({
    @Path('id') required String id,
    @Body() required UpdateProviderDto body,
  });

  @POST('/api/v1/admin/opportunity-providers/{id}/verify')
  Future<PostApiV1AdminOpportunityProvidersIdVerifyResponse> verifyProvider({
    @Path('id') required String id,
    @Body() required VerifyProviderDto body,
  });

  @POST('/api/v1/admin/opportunities/import/preview')
  Future<PostApiV1AdminOpportunitiesImportPreviewResponse> previewImport({
    @Body() required ImportCsvDto body,
  });

  @POST('/api/v1/admin/opportunities/import')
  Future<PostApiV1AdminOpportunitiesImportResponse> commitImport({
    @Body() required ImportCsvDto body,
  });

  @GET('/api/v1/admin/opportunities/link-health')
  Future<GetApiV1AdminOpportunitiesLinkHealthResponse> linkHealth({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('result') Result? result = Result.broken,
  });

  /// [brokenLink] - Only listings whose link was found broken.
  @GET('/api/v1/admin/opportunities')
  Future<GetApiV1AdminOpportunitiesResponse> list({
    @Query('status') OpportunityStatus? status,
    @Query('type') OpportunityType? type,
    @Query('providerId') String? providerId,
    @Query('q') String? q,
    @Query('brokenLink') bool? brokenLink,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/opportunities')
  Future<PostApiV1AdminOpportunitiesResponse> create({
    @Body() required OpportunityFieldsDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/admin/opportunities/{id}')
  Future<GetApiV1AdminOpportunitiesIdResponse> getApiV1AdminOpportunitiesId({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/opportunities/{id}')
  Future<PatchApiV1AdminOpportunitiesIdResponse> update({
    @Path('id') required String id,
    @Body() required UpdateOpportunityDto body,
  });

  @POST('/api/v1/admin/opportunities/{id}/publish')
  Future<PostApiV1AdminOpportunitiesIdPublishResponse> publish({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/opportunities/{id}/close')
  Future<PostApiV1AdminOpportunitiesIdCloseResponse> close({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/opportunities/{id}/archive')
  Future<PostApiV1AdminOpportunitiesIdArchiveResponse> archive({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/opportunities/{id}/remove')
  Future<PostApiV1AdminOpportunitiesIdRemoveResponse> remove({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/opportunities/{id}/reject')
  Future<PostApiV1AdminOpportunitiesIdRejectResponse> reject({
    @Path('id') required String id,
    @Body() required RejectOpportunityDto body,
  });

  @POST('/api/v1/admin/opportunities/{id}/feature')
  Future<PostApiV1AdminOpportunitiesIdFeatureResponse> feature({
    @Path('id') required String id,
    @Body() required FeatureOpportunityDto body,
  });

  @POST('/api/v1/admin/opportunities/{id}/set-trust')
  Future<PostApiV1AdminOpportunitiesIdSetTrustResponse> setTrust({
    @Path('id') required String id,
    @Body() required SetTrustDto body,
  });

  @POST('/api/v1/admin/opportunities/{id}/verify')
  Future<PostApiV1AdminOpportunitiesIdVerifyResponse> verify({
    @Path('id') required String id,
    @Body() required VerifyOpportunityDto body,
  });
}
