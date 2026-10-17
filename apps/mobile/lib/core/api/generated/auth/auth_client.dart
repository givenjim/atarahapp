// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_api_v1_auth_sessions_id_response.dart';
import '../models/get_api_v1_auth_sessions_response.dart';
import '../models/google_sign_in_dto.dart';
import '../models/identifier_dto.dart';
import '../models/login_dto.dart';
import '../models/post_api_v1_auth_google_response.dart';
import '../models/post_api_v1_auth_login_response.dart';
import '../models/post_api_v1_auth_logout_all_response.dart';
import '../models/post_api_v1_auth_logout_response.dart';
import '../models/post_api_v1_auth_password_forgot_response.dart';
import '../models/post_api_v1_auth_password_reset_response.dart';
import '../models/post_api_v1_auth_refresh_response.dart';
import '../models/post_api_v1_auth_register_response.dart';
import '../models/post_api_v1_auth_resend_code_response.dart';
import '../models/post_api_v1_auth_verify_response.dart';
import '../models/refresh_dto.dart';
import '../models/register_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/verify_dto.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  @POST('/api/v1/auth/register')
  Future<PostApiV1AuthRegisterResponse> register({
    @Body() required RegisterDto body,
  });

  @POST('/api/v1/auth/verify')
  Future<PostApiV1AuthVerifyResponse> verify({@Body() required VerifyDto body});

  @POST('/api/v1/auth/resend-code')
  Future<PostApiV1AuthResendCodeResponse> resend({
    @Body() required IdentifierDto body,
  });

  @POST('/api/v1/auth/login')
  Future<PostApiV1AuthLoginResponse> login({@Body() required LoginDto body});

  @POST('/api/v1/auth/refresh')
  Future<PostApiV1AuthRefreshResponse> refresh({
    @Body() required RefreshDto body,
  });

  @POST('/api/v1/auth/logout')
  Future<PostApiV1AuthLogoutResponse> logout();

  @POST('/api/v1/auth/logout-all')
  Future<PostApiV1AuthLogoutAllResponse> logoutAll();

  @POST('/api/v1/auth/password/forgot')
  Future<PostApiV1AuthPasswordForgotResponse> forgot({
    @Body() required IdentifierDto body,
  });

  @POST('/api/v1/auth/password/reset')
  Future<PostApiV1AuthPasswordResetResponse> reset({
    @Body() required ResetPasswordDto body,
  });

  @POST('/api/v1/auth/google')
  Future<PostApiV1AuthGoogleResponse> google({
    @Body() required GoogleSignInDto body,
  });

  @GET('/api/v1/auth/sessions')
  Future<GetApiV1AuthSessionsResponse> list();

  @DELETE('/api/v1/auth/sessions/{id}')
  Future<DeleteApiV1AuthSessionsIdResponse> revoke({
    @Path('id') required String id,
  });
}
