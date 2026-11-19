// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/category_fields_dto.dart';
import '../models/content_fields_dto.dart';
import '../models/delete_api_v1_admin_courses_id_lessons_lesson_id_response.dart';
import '../models/get_api_v1_admin_learning_analytics_response.dart';
import '../models/get_api_v1_admin_learning_categories_response.dart';
import '../models/get_api_v1_admin_learning_contents_id_response.dart';
import '../models/get_api_v1_admin_learning_contents_response.dart';
import '../models/get_api_v1_admin_learning_embed_hosts_response.dart';
import '../models/learning_content_type.dart';
import '../models/lesson_fields_dto.dart';
import '../models/patch_api_v1_admin_courses_id_lessons_lesson_id_response.dart';
import '../models/patch_api_v1_admin_learning_categories_id_response.dart';
import '../models/patch_api_v1_admin_learning_contents_id_response.dart';
import '../models/post_api_v1_admin_courses_id_lessons_response.dart';
import '../models/post_api_v1_admin_learning_categories_response.dart';
import '../models/post_api_v1_admin_learning_contents_id_archive_response.dart';
import '../models/post_api_v1_admin_learning_contents_id_publish_response.dart';
import '../models/post_api_v1_admin_learning_contents_id_unpublish_response.dart';
import '../models/post_api_v1_admin_learning_contents_response.dart';
import '../models/post_api_v1_admin_learning_progress_overrides_response.dart';
import '../models/progress_override_dto.dart';
import '../models/publication_status.dart';
import '../models/put_api_v1_admin_courses_id_lessons_order_response.dart';
import '../models/reorder_lessons_dto.dart';
import '../models/update_category_dto.dart';
import '../models/update_content_dto.dart';
import '../models/update_lesson_dto.dart';

part 'admin_learning_client.g.dart';

@RestApi()
abstract class AdminLearningClient {
  factory AdminLearningClient(Dio dio, {String? baseUrl}) = _AdminLearningClient;

  @GET('/api/v1/admin/learning/embed-hosts')
  Future<GetApiV1AdminLearningEmbedHostsResponse> hosts();

  @GET('/api/v1/admin/learning/categories')
  Future<GetApiV1AdminLearningCategoriesResponse> categories();

  @POST('/api/v1/admin/learning/categories')
  Future<PostApiV1AdminLearningCategoriesResponse> createCategory({
    @Body() required CategoryFieldsDto body,
  });

  @PATCH('/api/v1/admin/learning/categories/{id}')
  Future<PatchApiV1AdminLearningCategoriesIdResponse> updateCategory({
    @Path('id') required String id,
    @Body() required UpdateCategoryDto body,
  });

  @GET('/api/v1/admin/learning/analytics')
  Future<GetApiV1AdminLearningAnalyticsResponse> analytics();

  @POST('/api/v1/admin/learning/progress-overrides')
  Future<PostApiV1AdminLearningProgressOverridesResponse> progressOverride({
    @Body() required ProgressOverrideDto body,
  });

  /// [brokenLink] - Only items whose link or embed was found broken.
  @GET('/api/v1/admin/learning/contents')
  Future<GetApiV1AdminLearningContentsResponse> list({
    @Query('status') PublicationStatus? status,
    @Query('type') LearningContentType? type,
    @Query('categoryId') String? categoryId,
    @Query('q') String? q,
    @Query('brokenLink') bool? brokenLink,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/learning/contents')
  Future<PostApiV1AdminLearningContentsResponse> create({
    @Body() required ContentFieldsDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/admin/learning/contents/{id}')
  Future<GetApiV1AdminLearningContentsIdResponse> getApiV1AdminLearningContentsId({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/learning/contents/{id}')
  Future<PatchApiV1AdminLearningContentsIdResponse> update({
    @Path('id') required String id,
    @Body() required UpdateContentDto body,
  });

  @POST('/api/v1/admin/learning/contents/{id}/publish')
  Future<PostApiV1AdminLearningContentsIdPublishResponse> publish({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/learning/contents/{id}/unpublish')
  Future<PostApiV1AdminLearningContentsIdUnpublishResponse> unpublish({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/learning/contents/{id}/archive')
  Future<PostApiV1AdminLearningContentsIdArchiveResponse> archive({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/courses/{id}/lessons')
  Future<PostApiV1AdminCoursesIdLessonsResponse> addLesson({
    @Path('id') required String id,
    @Body() required LessonFieldsDto body,
  });

  @PUT('/api/v1/admin/courses/{id}/lessons/order')
  Future<PutApiV1AdminCoursesIdLessonsOrderResponse> reorder({
    @Path('id') required String id,
    @Body() required ReorderLessonsDto body,
  });

  @PATCH('/api/v1/admin/courses/{id}/lessons/{lessonId}')
  Future<PatchApiV1AdminCoursesIdLessonsLessonIdResponse> updateLesson({
    @Path('id') required String id,
    @Path('lessonId') required String lessonId,
    @Body() required UpdateLessonDto body,
  });

  @DELETE('/api/v1/admin/courses/{id}/lessons/{lessonId}')
  Future<DeleteApiV1AdminCoursesIdLessonsLessonIdResponse> deleteLesson({
    @Path('id') required String id,
    @Path('lessonId') required String lessonId,
  });
}
