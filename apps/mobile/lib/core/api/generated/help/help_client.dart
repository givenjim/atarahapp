// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_help_articles_slug_response.dart';
import '../models/get_api_v1_help_contact_response.dart';
import '../models/get_api_v1_help_faq_response.dart';
import '../models/get_api_v1_help_response.dart';
import '../models/get_api_v1_legal_documents_type_response.dart';
import '../models/get_api_v1_legal_response.dart';

part 'help_client.g.dart';

@RestApi()
abstract class HelpClient {
  factory HelpClient(Dio dio, {String? baseUrl}) = _HelpClient;

  /// [q] - Search the articles and the FAQ.
  @GET('/api/v1/help')
  Future<GetApiV1HelpResponse> search({@Query('q') String? q});

  @GET('/api/v1/help/articles/{slug}')
  Future<GetApiV1HelpArticlesSlugResponse> article({
    @Path('slug') required String slug,
  });

  @GET('/api/v1/help/faq')
  Future<GetApiV1HelpFaqResponse> faq();

  @GET('/api/v1/help/contact')
  Future<GetApiV1HelpContactResponse> contact();

  @GET('/api/v1/legal')
  Future<GetApiV1LegalResponse> legalList();

  @GET('/api/v1/legal/documents/{type}')
  Future<GetApiV1LegalDocumentsTypeResponse> legalDocument({
    @Path('type') required String type,
  });
}
