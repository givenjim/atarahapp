// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/deadline.dart';
import '../models/get_api_v1_me_opportunities_response.dart';
import '../models/get_api_v1_opportunities_home_response.dart';
import '../models/get_api_v1_opportunities_id_response.dart';
import '../models/get_api_v1_opportunities_response.dart';
import '../models/opportunity_trust.dart';
import '../models/opportunity_type.dart';
import '../models/post_api_v1_opportunities_id_track_response.dart';
import '../models/put_api_v1_opportunities_id_save_response.dart';
import '../models/sort2.dart';
import '../models/tab.dart';
import '../models/track_opportunity_dto.dart';

part 'opportunities_client.g.dart';

@RestApi()
abstract class OpportunitiesClient {
  factory OpportunitiesClient(Dio dio, {String? baseUrl}) =
      _OpportunitiesClient;

  @GET('/api/v1/opportunities/home')
  Future<GetApiV1OpportunitiesHomeResponse> home();

  /// [q] - Title, summary or provider.
  ///
  /// [remote] - Only remote opportunities.
  ///
  /// [deadline] - Closing within 7, 14 or 30 days.
  @GET('/api/v1/opportunities')
  Future<GetApiV1OpportunitiesResponse> list({
    @Query('type') OpportunityType? type,
    @Query('q') String? q,
    @Query('disciplineId') String? disciplineId,
    @Query('countyId') String? countyId,
    @Query('remote') bool? remote,
    @Query('deadline') Deadline? deadline,
    @Query('trust') OpportunityTrust? trust,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('sort') Sort2? sort = Sort2.deadline,
  });

  /// [refresh] - Skip the 5 minute cache of the profile check (after editing a profile).
  @GET('/api/v1/opportunities/{id}')
  Future<GetApiV1OpportunitiesIdResponse> detail({
    @Path('id') required String id,
    @Query('refresh') bool? refresh,
  });

  @PUT('/api/v1/opportunities/{id}/save')
  Future<PutApiV1OpportunitiesIdSaveResponse> save({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/opportunities/{id}/save')
  Future<void> unsave({@Path('id') required String id});

  @POST('/api/v1/opportunities/{id}/track')
  Future<PostApiV1OpportunitiesIdTrackResponse> track({
    @Path('id') required String id,
    @Body() required TrackOpportunityDto body,
  });

  @GET('/api/v1/me/opportunities')
  Future<GetApiV1MeOpportunitiesResponse> mine({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('tab') Tab? tab = Tab.all,
  });
}
