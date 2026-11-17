// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_api_v1_auth_sessions_id_response.dart';
import '../models/get_api_v1_auth_sessions_response.dart';
import '../models/post_api_v1_auth_sessions_revoke_others_response.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  @GET('/api/v1/auth/sessions')
  Future<GetApiV1AuthSessionsResponse> list();

  @DELETE('/api/v1/auth/sessions/{id}')
  Future<DeleteApiV1AuthSessionsIdResponse> revoke({
    @Path('id') required String id,
  });

  @POST('/api/v1/auth/sessions/revoke-others')
  Future<PostApiV1AuthSessionsRevokeOthersResponse> revokeOthers();
}
