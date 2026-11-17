// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/faq_fields_dto.dart';
import '../models/get_api_v1_admin_faq_response.dart';
import '../models/get_api_v1_admin_help_articles_id_response.dart';
import '../models/get_api_v1_admin_help_articles_response.dart';
import '../models/get_api_v1_admin_legal_documents_response.dart';
import '../models/help_article_fields_dto.dart';
import '../models/new_legal_version_dto.dart';
import '../models/patch_api_v1_admin_faq_id_response.dart';
import '../models/patch_api_v1_admin_help_articles_id_response.dart';
import '../models/patch_api_v1_admin_legal_documents_id_response.dart';
import '../models/post_api_v1_admin_faq_response.dart';
import '../models/post_api_v1_admin_help_articles_response.dart';
import '../models/post_api_v1_admin_legal_documents_id_publish_response.dart';
import '../models/post_api_v1_admin_legal_documents_response.dart';
import '../models/publish_legal_dto.dart';
import '../models/update_faq_dto.dart';
import '../models/update_help_article_dto.dart';
import '../models/update_legal_draft_dto.dart';

part 'admin_help_client.g.dart';

@RestApi()
abstract class AdminHelpClient {
  factory AdminHelpClient(Dio dio, {String? baseUrl}) = _AdminHelpClient;

  @GET('/api/v1/admin/help-articles')
  Future<GetApiV1AdminHelpArticlesResponse> listArticles({
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/help-articles')
  Future<PostApiV1AdminHelpArticlesResponse> createArticle({
    @Body() required HelpArticleFieldsDto body,
  });

  @GET('/api/v1/admin/help-articles/{id}')
  Future<GetApiV1AdminHelpArticlesIdResponse> getArticle({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/help-articles/{id}')
  Future<PatchApiV1AdminHelpArticlesIdResponse> updateArticle({
    @Path('id') required String id,
    @Body() required UpdateHelpArticleDto body,
  });

  @DELETE('/api/v1/admin/help-articles/{id}')
  Future<void> deleteArticle({@Path('id') required String id});

  @GET('/api/v1/admin/faq')
  Future<GetApiV1AdminFaqResponse> listFaq({
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/faq')
  Future<PostApiV1AdminFaqResponse> createFaq({
    @Body() required FaqFieldsDto body,
  });

  @PATCH('/api/v1/admin/faq/{id}')
  Future<PatchApiV1AdminFaqIdResponse> updateFaq({
    @Path('id') required String id,
    @Body() required UpdateFaqDto body,
  });

  @DELETE('/api/v1/admin/faq/{id}')
  Future<void> deleteFaq({@Path('id') required String id});

  @GET('/api/v1/admin/legal-documents')
  Future<GetApiV1AdminLegalDocumentsResponse> listLegal({
    @Query('type') required String type,
  });

  @POST('/api/v1/admin/legal-documents')
  Future<PostApiV1AdminLegalDocumentsResponse> newVersion({
    @Body() required NewLegalVersionDto body,
  });

  @PATCH('/api/v1/admin/legal-documents/{id}')
  Future<PatchApiV1AdminLegalDocumentsIdResponse> updateDraft({
    @Path('id') required String id,
    @Body() required UpdateLegalDraftDto body,
  });

  @POST('/api/v1/admin/legal-documents/{id}/publish')
  Future<PostApiV1AdminLegalDocumentsIdPublishResponse> publish({
    @Path('id') required String id,
    @Body() required PublishLegalDto body,
  });
}
