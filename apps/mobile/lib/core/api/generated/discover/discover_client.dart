// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_creatives_response.dart';
import '../models/get_api_v1_home_response.dart';
import '../models/get_api_v1_me_recent_searches_response.dart';
import '../models/get_api_v1_search_response.dart';
import '../models/post_api_v1_me_recent_searches_response.dart';
import '../models/record_search_dto.dart';
import '../models/sort.dart';
import '../models/type2.dart';

part 'discover_client.g.dart';

@RestApi()
abstract class DiscoverClient {
  factory DiscoverClient(Dio dio, {String? baseUrl}) = _DiscoverClient;

  @GET('/api/v1/home')
  Future<GetApiV1HomeResponse> homeFeed();

  /// [q] - Name, headline, discipline or skill.
  ///
  /// [countyId] - Only people who chose to show their county to you.
  ///
  /// [available] - Only people open to commissions.
  ///
  /// [verified] - Only people Atarah has verified.
  @GET('/api/v1/creatives')
  Future<GetApiV1CreativesResponse> creativeList({
    @Query('q') String? q,
    @Query('disciplineId') String? disciplineId,
    @Query('specialisationId') String? specialisationId,
    @Query('countyId') String? countyId,
    @Query('available') bool? available,
    @Query('verified') bool? verified,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('sort') Sort? sort = Sort.relevance,
  });

  /// [type] - One kind of result, paged. Leave out for every kind, three each.
  @GET('/api/v1/search')
  Future<GetApiV1SearchResponse> find({
    @Query('q') required String q,
    @Query('type') Type2? type,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/me/recent-searches')
  Future<GetApiV1MeRecentSearchesResponse> recent();

  @POST('/api/v1/me/recent-searches')
  Future<PostApiV1MeRecentSearchesResponse> record({
    @Body() required RecordSearchDto body,
  });

  @DELETE('/api/v1/me/recent-searches')
  Future<void> clear();

  @DELETE('/api/v1/me/recent-searches/{id}')
  Future<void> remove({@Path('id') required String id});
}
