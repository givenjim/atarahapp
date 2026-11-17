// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_me_saved_counts_response.dart';
import '../models/get_api_v1_me_saved_response.dart';
import '../models/save_body_dto.dart';
import '../models/saved_kind.dart';
import '../models/type2.dart';

part 'saved_client.g.dart';

@RestApi()
abstract class SavedClient {
  factory SavedClient(Dio dio, {String? baseUrl}) = _SavedClient;

  /// [type] - Only this kind. Omit for everything.
  ///
  /// [collection] - Only this collection.
  @GET('/api/v1/me/saved')
  Future<GetApiV1MeSavedResponse> list({
    @Query('type') SavedKind? type,
    @Query('collection') String? collection,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/me/saved/counts')
  Future<GetApiV1MeSavedCountsResponse> counts();

  @PUT('/api/v1/me/saved/{type}/{id}')
  Future<void> save({
    @Path('type') required Type2 type,
    @Path('id') required String id,
    @Body() required SaveBodyDto body,
  });

  @DELETE('/api/v1/me/saved/{type}/{id}')
  Future<void> unsave({
    @Path('type') required Type2 type,
    @Path('id') required String id,
  });
}
