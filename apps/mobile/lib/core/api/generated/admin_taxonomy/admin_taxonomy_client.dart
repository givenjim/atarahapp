// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/approve_suggestion_dto.dart';
import '../models/create_taxonomy_item_dto.dart';
import '../models/get_api_v1_admin_specialisation_suggestions_response.dart';
import '../models/get_api_v1_admin_taxonomy_kind_response.dart';
import '../models/kind.dart';
import '../models/merge_suggestion_dto.dart';
import '../models/patch_api_v1_admin_taxonomy_kind_id_response.dart';
import '../models/post_api_v1_admin_specialisation_suggestions_id_approve_response.dart';
import '../models/post_api_v1_admin_specialisation_suggestions_id_merge_response.dart';
import '../models/post_api_v1_admin_specialisation_suggestions_id_reject_response.dart';
import '../models/post_api_v1_admin_taxonomy_kind_reorder_response.dart';
import '../models/post_api_v1_admin_taxonomy_kind_response.dart';
import '../models/reject_suggestion_dto.dart';
import '../models/reorder_taxonomy_dto.dart';
import '../models/status2.dart';
import '../models/update_taxonomy_item_dto.dart';

part 'admin_taxonomy_client.g.dart';

@RestApi()
abstract class AdminTaxonomyClient {
  factory AdminTaxonomyClient(Dio dio, {String? baseUrl}) =
      _AdminTaxonomyClient;

  /// [disciplineId] - Specialisations and skills: only this discipline (id).
  ///
  /// [includeArchived] - Include archived entries. Default true for admins.
  @GET('/api/v1/admin/taxonomy/{kind}')
  Future<GetApiV1AdminTaxonomyKindResponse> listTaxonomy({
    @Path('kind') required Kind kind,
    @Query('disciplineId') String? disciplineId,
    @Query('includeArchived') bool? includeArchived,
  });

  @POST('/api/v1/admin/taxonomy/{kind}')
  Future<PostApiV1AdminTaxonomyKindResponse> createTaxonomy({
    @Path('kind') required Kind kind,
    @Body() required CreateTaxonomyItemDto body,
  });

  @POST('/api/v1/admin/taxonomy/{kind}/reorder')
  Future<PostApiV1AdminTaxonomyKindReorderResponse> reorderTaxonomy({
    @Path('kind') required Kind kind,
    @Body() required ReorderTaxonomyDto body,
  });

  @PATCH('/api/v1/admin/taxonomy/{kind}/{id}')
  Future<PatchApiV1AdminTaxonomyKindIdResponse> updateTaxonomy({
    @Path('kind') required Kind kind,
    @Path('id') required String id,
    @Body() required UpdateTaxonomyItemDto body,
  });

  @GET('/api/v1/admin/specialisation-suggestions')
  Future<GetApiV1AdminSpecialisationSuggestionsResponse> listSuggestions({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
    @Query('status') Status2? status,
  });

  @POST('/api/v1/admin/specialisation-suggestions/{id}/approve')
  Future<PostApiV1AdminSpecialisationSuggestionsIdApproveResponse>
  approveSuggestion({
    @Path('id') required String id,
    @Body() required ApproveSuggestionDto body,
  });

  @POST('/api/v1/admin/specialisation-suggestions/{id}/merge')
  Future<PostApiV1AdminSpecialisationSuggestionsIdMergeResponse>
  mergeSuggestion({
    @Path('id') required String id,
    @Body() required MergeSuggestionDto body,
  });

  @POST('/api/v1/admin/specialisation-suggestions/{id}/reject')
  Future<PostApiV1AdminSpecialisationSuggestionsIdRejectResponse>
  rejectSuggestion({
    @Path('id') required String id,
    @Body() required RejectSuggestionDto body,
  });
}
