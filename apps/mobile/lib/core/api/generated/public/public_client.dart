// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_config_public_response.dart';
import '../models/get_api_v1_legal_type_response.dart';

part 'public_client.g.dart';

@RestApi()
abstract class PublicClient {
  factory PublicClient(Dio dio, {String? baseUrl}) = _PublicClient;

  @GET('/api/v1/config/public')
  Future<GetApiV1ConfigPublicResponse> config();

  @GET('/api/v1/legal/{type}')
  Future<GetApiV1LegalTypeResponse> legal({@Path('type') required String type});
}
