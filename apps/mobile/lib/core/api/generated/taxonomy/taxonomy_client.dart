// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_taxonomy_development_areas_response.dart';
import '../models/get_api_v1_taxonomy_disciplines_response.dart';
import '../models/get_api_v1_taxonomy_interests_response.dart';
import '../models/get_api_v1_taxonomy_skills_response.dart';
import '../models/post_api_v1_taxonomy_specialisations_suggestions_response.dart';
import '../models/suggest_specialisation_dto.dart';

part 'taxonomy_client.g.dart';

@RestApi()
abstract class TaxonomyClient {
  factory TaxonomyClient(Dio dio, {String? baseUrl}) = _TaxonomyClient;

  @GET('/api/v1/taxonomy/disciplines')
  Future<GetApiV1TaxonomyDisciplinesResponse> disciplines();

  /// [discipline] - Discipline id or slug. Returns general skills plus that discipline’s skills.
  @GET('/api/v1/taxonomy/skills')
  Future<GetApiV1TaxonomySkillsResponse> skills({
    @Query('discipline') String? discipline,
  });

  @GET('/api/v1/taxonomy/interests')
  Future<GetApiV1TaxonomyInterestsResponse> interests();

  @GET('/api/v1/taxonomy/development-areas')
  Future<GetApiV1TaxonomyDevelopmentAreasResponse> developmentAreas();

  @POST('/api/v1/taxonomy/specialisations/suggestions')
  Future<PostApiV1TaxonomySpecialisationsSuggestionsResponse> suggest({
    @Body() required SuggestSpecialisationDto body,
  });
}
