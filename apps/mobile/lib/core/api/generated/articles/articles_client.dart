// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_articles_response.dart';
import '../models/get_api_v1_articles_slug_response.dart';
import '../models/get_api_v1_me_saved_response.dart';
import '../models/type.dart';

part 'articles_client.g.dart';

@RestApi()
abstract class ArticlesClient {
  factory ArticlesClient(Dio dio, {String? baseUrl}) = _ArticlesClient;

  /// [tag] - Only articles with this tag.
  @GET('/api/v1/articles')
  Future<GetApiV1ArticlesResponse> list({
    @Query('tag') String? tag,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/articles/{slug}')
  Future<GetApiV1ArticlesSlugResponse> detail({
    @Path('slug') required String slug,
  });

  @GET('/api/v1/me/saved')
  Future<GetApiV1MeSavedResponse> saved({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('type') Type? type = Type.article,
  });

  @PUT('/api/v1/me/saved/{type}/{id}')
  Future<void> save({
    @Path('type') required Type type,
    @Path('id') required String id,
  });

  @DELETE('/api/v1/me/saved/{type}/{id}')
  Future<void> unsave({
    @Path('type') required Type type,
    @Path('id') required String id,
  });
}
