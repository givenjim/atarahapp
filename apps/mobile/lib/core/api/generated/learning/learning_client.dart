// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_learning_categories_slug_response.dart';
import '../models/get_api_v1_learning_id_response.dart';
import '../models/get_api_v1_learning_lessons_id_response.dart';
import '../models/get_api_v1_learning_lessons_id_video_response.dart';
import '../models/get_api_v1_learning_response.dart';
import '../models/get_api_v1_learning_search_response.dart';
import '../models/get_api_v1_me_learning_response.dart';
import '../models/get_api_v1_me_learning_stats_response.dart';
import '../models/learning_content_type.dart';
import '../models/lesson_progress_body_dto.dart';
import '../models/post_api_v1_learning_id_complete_response.dart';
import '../models/post_api_v1_learning_id_enrol_response.dart';
import '../models/post_api_v1_learning_id_start_response.dart';
import '../models/put_api_v1_learning_lessons_id_progress_response.dart';
import '../models/tab2.dart';

part 'learning_client.g.dart';

@RestApi()
abstract class LearningClient {
  factory LearningClient(Dio dio, {String? baseUrl}) = _LearningClient;

  @GET('/api/v1/learning')
  Future<GetApiV1LearningResponse> hub();

  @GET('/api/v1/learning/search')
  Future<GetApiV1LearningSearchResponse> search({
    @Query('q') String? q,
    @Query('type') LearningContentType? type,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/learning/categories/{slug}')
  Future<GetApiV1LearningCategoriesSlugResponse> category({
    @Path('slug') required String slug,
    @Query('type') LearningContentType? type,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/learning/lessons/{id}')
  Future<GetApiV1LearningLessonsIdResponse> lesson({
    @Path('id') required String id,
  });

  @GET('/api/v1/learning/lessons/{id}/video')
  Future<GetApiV1LearningLessonsIdVideoResponse> video({
    @Path('id') required String id,
  });

  @PUT('/api/v1/learning/lessons/{id}/progress')
  Future<PutApiV1LearningLessonsIdProgressResponse> progress({
    @Path('id') required String id,
    @Body() required LessonProgressBodyDto body,
  });

  @GET('/api/v1/learning/{id}')
  Future<GetApiV1LearningIdResponse> detail({@Path('id') required String id});

  @POST('/api/v1/learning/{id}/enrol')
  Future<PostApiV1LearningIdEnrolResponse> enrol({
    @Path('id') required String id,
  });

  @POST('/api/v1/learning/{id}/start')
  Future<PostApiV1LearningIdStartResponse> start({
    @Path('id') required String id,
  });

  @POST('/api/v1/learning/{id}/complete')
  Future<PostApiV1LearningIdCompleteResponse> complete({
    @Path('id') required String id,
  });

  @PUT('/api/v1/learning/{id}/save')
  Future<void> save({@Path('id') required String id});

  @DELETE('/api/v1/learning/{id}/save')
  Future<void> unsave({@Path('id') required String id});

  @GET('/api/v1/me/learning')
  Future<GetApiV1MeLearningResponse> mine({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('tab') Tab2? tab = Tab2.active,
  });

  @GET('/api/v1/me/learning/stats')
  Future<GetApiV1MeLearningStatsResponse> stats();
}
