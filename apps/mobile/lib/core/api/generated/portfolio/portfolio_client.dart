// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/achievement_input_dto.dart';
import '../models/add_collaborator_dto.dart';
import '../models/category.dart';
import '../models/create_project_dto.dart';
import '../models/delete_api_v1_me_projects_id_collaborators_collaborator_id_response.dart';
import '../models/experience_input_dto.dart';
import '../models/get_api_v1_creatives_handle_achievements_response.dart';
import '../models/get_api_v1_creatives_handle_experience_response.dart';
import '../models/get_api_v1_creatives_handle_projects_id_response.dart';
import '../models/get_api_v1_creatives_handle_projects_response.dart';
import '../models/get_api_v1_creatives_handle_services_response.dart';
import '../models/get_api_v1_creatives_handle_skills_response.dart';
import '../models/get_api_v1_me_achievements_response.dart';
import '../models/get_api_v1_me_collaborations_response.dart';
import '../models/get_api_v1_me_experience_response.dart';
import '../models/get_api_v1_me_projects_id_response.dart';
import '../models/get_api_v1_me_projects_response.dart';
import '../models/get_api_v1_me_services_response.dart';
import '../models/get_api_v1_me_skills_response.dart';
import '../models/get_api_v1_members_search_response.dart';
import '../models/list_filter.dart';
import '../models/patch_api_v1_me_achievements_id_response.dart';
import '../models/patch_api_v1_me_experience_id_response.dart';
import '../models/patch_api_v1_me_projects_id_response.dart';
import '../models/patch_api_v1_me_services_id_response.dart';
import '../models/post_api_v1_me_achievements_response.dart';
import '../models/post_api_v1_me_collaborations_id_accept_response.dart';
import '../models/post_api_v1_me_experience_response.dart';
import '../models/post_api_v1_me_projects_id_collaborators_response.dart';
import '../models/post_api_v1_me_projects_id_publish_response.dart';
import '../models/post_api_v1_me_projects_response.dart';
import '../models/post_api_v1_me_services_response.dart';
import '../models/preview_as.dart';
import '../models/put_api_v1_me_skills_skill_id_response.dart';
import '../models/service_input_dto.dart';
import '../models/set_skill_dto.dart';
import '../models/update_achievement_dto.dart';
import '../models/update_experience_dto.dart';
import '../models/update_project_dto.dart';
import '../models/update_service_dto.dart';

part 'portfolio_client.g.dart';

@RestApi()
abstract class PortfolioClient {
  factory PortfolioClient(Dio dio, {String? baseUrl}) = _PortfolioClient;

  @GET('/api/v1/me/projects')
  Future<GetApiV1MeProjectsResponse> myProjects({
    @Query('listFilter') ListFilter? listFilter = ListFilter.all,
  });

  @POST('/api/v1/me/projects')
  Future<PostApiV1MeProjectsResponse> createProject({
    @Body() required CreateProjectDto body,
  });

  @GET('/api/v1/me/projects/{id}')
  Future<GetApiV1MeProjectsIdResponse> myProject({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/me/projects/{id}')
  Future<PatchApiV1MeProjectsIdResponse> updateProject({
    @Path('id') required String id,
    @Body() required UpdateProjectDto body,
  });

  @DELETE('/api/v1/me/projects/{id}')
  Future<void> deleteProject({@Path('id') required String id});

  @POST('/api/v1/me/projects/{id}/publish')
  Future<PostApiV1MeProjectsIdPublishResponse> publishProject({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/projects/{id}/collaborators')
  Future<PostApiV1MeProjectsIdCollaboratorsResponse> addCollaborator({
    @Path('id') required String id,
    @Body() required AddCollaboratorDto body,
  });

  @DELETE('/api/v1/me/projects/{id}/collaborators/{collaboratorId}')
  Future<DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse>
  removeCollaborator({
    @Path('id') required String id,
    @Path('collaboratorId') required String collaboratorId,
  });

  @GET('/api/v1/me/collaborations')
  Future<GetApiV1MeCollaborationsResponse> myCollaborations();

  @POST('/api/v1/me/collaborations/{id}/accept')
  Future<PostApiV1MeCollaborationsIdAcceptResponse> acceptCollaboration({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/me/collaborations/{id}')
  Future<void> leaveCollaboration({@Path('id') required String id});

  @GET('/api/v1/members/search')
  Future<GetApiV1MembersSearchResponse> searchMembers({
    @Query('q') required String q,
    @Query('limit') num? limit = 10,
  });

  @GET('/api/v1/me/skills')
  Future<GetApiV1MeSkillsResponse> mySkills();

  @PUT('/api/v1/me/skills/{skillId}')
  Future<PutApiV1MeSkillsSkillIdResponse> setSkill({
    @Path('skillId') required String skillId,
    @Body() required SetSkillDto body,
  });

  @DELETE('/api/v1/me/skills/{skillId}')
  Future<void> removeSkill({@Path('skillId') required String skillId});

  @GET('/api/v1/me/experience')
  Future<GetApiV1MeExperienceResponse> myExperience();

  @POST('/api/v1/me/experience')
  Future<PostApiV1MeExperienceResponse> addExperience({
    @Body() required ExperienceInputDto body,
  });

  @PATCH('/api/v1/me/experience/{id}')
  Future<PatchApiV1MeExperienceIdResponse> updateExperience({
    @Path('id') required String id,
    @Body() required UpdateExperienceDto body,
  });

  @DELETE('/api/v1/me/experience/{id}')
  Future<void> deleteExperience({@Path('id') required String id});

  @GET('/api/v1/me/achievements')
  Future<GetApiV1MeAchievementsResponse> myAchievements();

  @POST('/api/v1/me/achievements')
  Future<PostApiV1MeAchievementsResponse> addAchievement({
    @Body() required AchievementInputDto body,
  });

  @PATCH('/api/v1/me/achievements/{id}')
  Future<PatchApiV1MeAchievementsIdResponse> updateAchievement({
    @Path('id') required String id,
    @Body() required UpdateAchievementDto body,
  });

  @DELETE('/api/v1/me/achievements/{id}')
  Future<void> deleteAchievement({@Path('id') required String id});

  @GET('/api/v1/me/services')
  Future<GetApiV1MeServicesResponse> myServices();

  @POST('/api/v1/me/services')
  Future<PostApiV1MeServicesResponse> addService({
    @Body() required ServiceInputDto body,
  });

  @PATCH('/api/v1/me/services/{id}')
  Future<PatchApiV1MeServicesIdResponse> updateService({
    @Path('id') required String id,
    @Body() required UpdateServiceDto body,
  });

  @DELETE('/api/v1/me/services/{id}')
  Future<void> deleteService({@Path('id') required String id});

  /// [previewAs] - Owner only: see the portfolio as the public or as other members do.
  ///
  /// [featuredOnly] - Only featured projects.
  @GET('/api/v1/creatives/{handle}/projects')
  Future<GetApiV1CreativesHandleProjectsResponse> creativeProjects({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
    @Query('category') Category? category,
    @Query('featuredOnly') bool? featuredOnly,
  });

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}/projects/{id}')
  Future<GetApiV1CreativesHandleProjectsIdResponse> creativeProject({
    @Path('handle') required String handle,
    @Path('id') required String id,
    @Query('previewAs') PreviewAs? previewAs,
  });

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}/skills')
  Future<GetApiV1CreativesHandleSkillsResponse> creativeSkills({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
  });

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}/experience')
  Future<GetApiV1CreativesHandleExperienceResponse> creativeExperience({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
  });

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}/achievements')
  Future<GetApiV1CreativesHandleAchievementsResponse> creativeAchievements({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
  });

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}/services')
  Future<GetApiV1CreativesHandleServicesResponse> creativeServices({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
  });
}
