// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_article_dto.dart';
import '../models/get_api_v1_admin_articles_id_response.dart';
import '../models/get_api_v1_admin_articles_response.dart';
import '../models/get_api_v1_admin_home_response.dart';
import '../models/patch_api_v1_admin_articles_id_response.dart';
import '../models/post_api_v1_admin_articles_id_archive_response.dart';
import '../models/post_api_v1_admin_articles_id_publish_response.dart';
import '../models/post_api_v1_admin_articles_id_restore_response.dart';
import '../models/post_api_v1_admin_articles_id_return_response.dart';
import '../models/post_api_v1_admin_articles_id_submit_response.dart';
import '../models/post_api_v1_admin_articles_response.dart';
import '../models/post_api_v1_admin_media_id_complete_response.dart';
import '../models/post_api_v1_admin_media_uploads_response.dart';
import '../models/publish_article_dto.dart';
import '../models/put_api_v1_admin_home_response.dart';
import '../models/request_upload_dto.dart';
import '../models/set_home_config_dto.dart';
import '../models/status3.dart';
import '../models/update_article_dto.dart';

part 'admin_content_client.g.dart';

@RestApi()
abstract class AdminContentClient {
  factory AdminContentClient(Dio dio, {String? baseUrl}) = _AdminContentClient;

  /// [q] - Title or byline contains.
  @GET('/api/v1/admin/articles')
  Future<GetApiV1AdminArticlesResponse> list({
    @Query('status') Status3? status,
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/articles')
  Future<PostApiV1AdminArticlesResponse> create({
    @Body() required CreateArticleDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/admin/articles/{id}')
  Future<GetApiV1AdminArticlesIdResponse> getApiV1AdminArticlesId({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/articles/{id}')
  Future<PatchApiV1AdminArticlesIdResponse> update({
    @Path('id') required String id,
    @Body() required UpdateArticleDto body,
  });

  @POST('/api/v1/admin/articles/{id}/submit')
  Future<PostApiV1AdminArticlesIdSubmitResponse> submit({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/articles/{id}/return')
  Future<PostApiV1AdminArticlesIdReturnResponse> returnToDraft({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/articles/{id}/publish')
  Future<PostApiV1AdminArticlesIdPublishResponse> publish({
    @Path('id') required String id,
    @Body() required PublishArticleDto body,
  });

  @POST('/api/v1/admin/articles/{id}/archive')
  Future<PostApiV1AdminArticlesIdArchiveResponse> archive({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/articles/{id}/restore')
  Future<PostApiV1AdminArticlesIdRestoreResponse> restore({
    @Path('id') required String id,
  });

  @GET('/api/v1/admin/home')
  Future<GetApiV1AdminHomeResponse> homeConfig();

  @PUT('/api/v1/admin/home')
  Future<PutApiV1AdminHomeResponse> setHomeConfig({
    @Body() required SetHomeConfigDto body,
  });

  @POST('/api/v1/admin/media/uploads')
  Future<PostApiV1AdminMediaUploadsResponse> requestUpload({
    @Body() required RequestUploadDto body,
  });

  @POST('/api/v1/admin/media/{id}/complete')
  Future<PostApiV1AdminMediaIdCompleteResponse> complete({
    @Path('id') required String id,
  });
}
