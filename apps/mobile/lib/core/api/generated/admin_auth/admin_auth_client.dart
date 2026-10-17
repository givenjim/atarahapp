// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/admin_login_dto.dart';
import '../models/admin_reauth_dto.dart';
import '../models/admin_totp_verify_dto.dart';
import '../models/challenge_dto.dart';
import '../models/get_api_v1_admin_auth_me_response.dart';
import '../models/post_api_v1_admin_auth_login_response.dart';
import '../models/post_api_v1_admin_auth_logout_response.dart';
import '../models/post_api_v1_admin_auth_reauth_response.dart';
import '../models/post_api_v1_admin_auth_refresh_response.dart';
import '../models/post_api_v1_admin_auth_totp_setup_response.dart';
import '../models/post_api_v1_admin_auth_totp_verify_response.dart';
import '../models/refresh_dto.dart';

part 'admin_auth_client.g.dart';

@RestApi()
abstract class AdminAuthClient {
  factory AdminAuthClient(Dio dio, {String? baseUrl}) = _AdminAuthClient;

  @POST('/api/v1/admin/auth/login')
  Future<PostApiV1AdminAuthLoginResponse> adminLogin({
    @Body() required AdminLoginDto body,
  });

  @POST('/api/v1/admin/auth/totp/setup')
  Future<PostApiV1AdminAuthTotpSetupResponse> totpSetup({
    @Body() required ChallengeDto body,
  });

  @POST('/api/v1/admin/auth/totp/verify')
  Future<PostApiV1AdminAuthTotpVerifyResponse> totpVerify({
    @Body() required AdminTotpVerifyDto body,
  });

  @POST('/api/v1/admin/auth/refresh')
  Future<PostApiV1AdminAuthRefreshResponse> adminRefresh({
    @Body() required RefreshDto body,
  });

  @POST('/api/v1/admin/auth/reauth')
  Future<PostApiV1AdminAuthReauthResponse> adminReauth({
    @Body() required AdminReauthDto body,
  });

  @POST('/api/v1/admin/auth/logout')
  Future<PostApiV1AdminAuthLogoutResponse> adminLogout();

  @GET('/api/v1/admin/auth/me')
  Future<GetApiV1AdminAuthMeResponse> adminMe();
}
