// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_provider_opportunities_id_response.dart';
import '../models/get_api_v1_provider_opportunities_response.dart';
import '../models/get_api_v1_provider_organisations_response.dart';
import '../models/opportunity_fields_dto.dart';
import '../models/opportunity_status.dart';
import '../models/opportunity_type.dart';
import '../models/patch_api_v1_provider_opportunities_id_response.dart';
import '../models/post_api_v1_provider_opportunities_response.dart';
import '../models/update_opportunity_dto.dart';

part 'provider_opportunities_client.g.dart';

@RestApi()
abstract class ProviderOpportunitiesClient {
  factory ProviderOpportunitiesClient(Dio dio, {String? baseUrl}) =
      _ProviderOpportunitiesClient;

  @GET('/api/v1/provider/organisations')
  Future<GetApiV1ProviderOrganisationsResponse> organisations();

  /// [brokenLink] - Only listings whose link was found broken.
  @GET('/api/v1/provider/opportunities')
  Future<GetApiV1ProviderOpportunitiesResponse> list({
    @Query('status') OpportunityStatus? status,
    @Query('type') OpportunityType? type,
    @Query('providerId') String? providerId,
    @Query('q') String? q,
    @Query('brokenLink') bool? brokenLink,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/provider/opportunities')
  Future<PostApiV1ProviderOpportunitiesResponse> submit({
    @Body() required OpportunityFieldsDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/provider/opportunities/{id}')
  Future<GetApiV1ProviderOpportunitiesIdResponse>
  getApiV1ProviderOpportunitiesId({@Path('id') required String id});

  @PATCH('/api/v1/provider/opportunities/{id}')
  Future<PatchApiV1ProviderOpportunitiesIdResponse> update({
    @Path('id') required String id,
    @Body() required UpdateOpportunityDto body,
  });
}
