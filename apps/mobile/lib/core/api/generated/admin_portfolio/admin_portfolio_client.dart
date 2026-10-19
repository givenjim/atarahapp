// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_admin_projects_id_response.dart';
import '../models/get_api_v1_admin_projects_response.dart';
import '../models/hide_project_dto.dart';
import '../models/post_api_v1_admin_projects_id_hide_response.dart';
import '../models/post_api_v1_admin_projects_id_restore_response.dart';

part 'admin_portfolio_client.g.dart';

@RestApi()
abstract class AdminPortfolioClient {
  factory AdminPortfolioClient(Dio dio, {String? baseUrl}) =
      _AdminPortfolioClient;

  /// [q] - Matches the title, the owner’s name or handle.
  ///
  /// [hiddenOnly] - Only projects a moderator has hidden.
  @GET('/api/v1/admin/projects')
  Future<GetApiV1AdminProjectsResponse> list({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('q') String? q,
    @Query('hiddenOnly') bool? hiddenOnly,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/admin/projects/{id}')
  Future<GetApiV1AdminProjectsIdResponse> getApiV1AdminProjectsId({
    @Path('id') required String id,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `hide`.
  @POST('/api/v1/admin/projects/{id}/hide')
  Future<PostApiV1AdminProjectsIdHideResponse> postApiV1AdminProjectsIdHide({
    @Path('id') required String id,
    @Body() required HideProjectDto body,
  });

  @POST('/api/v1/admin/projects/{id}/restore')
  Future<PostApiV1AdminProjectsIdRestoreResponse> restore({
    @Path('id') required String id,
  });
}
