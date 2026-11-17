// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/change_email_dto.dart';
import '../models/change_password_dto.dart';
import '../models/change_phone_dto.dart';
import '../models/delete_account_dto.dart';
import '../models/get_api_v1_me_account_response.dart';
import '../models/get_api_v1_me_export_response.dart';
import '../models/get_api_v1_me_membership_response.dart';
import '../models/get_api_v1_me_privacy_response.dart';
import '../models/get_api_v1_me_two_step_response.dart';
import '../models/patch_api_v1_me_account_response.dart';
import '../models/patch_api_v1_me_privacy_response.dart';
import '../models/post_api_v1_me_delete_response.dart';
import '../models/post_api_v1_me_email_change_response.dart';
import '../models/post_api_v1_me_export_response.dart';
import '../models/post_api_v1_me_password_response.dart';
import '../models/post_api_v1_me_phone_change_response.dart';
import '../models/post_api_v1_me_phone_verify_response.dart';
import '../models/post_api_v1_me_restore_response.dart';
import '../models/put_api_v1_me_two_step_response.dart';
import '../models/set_two_step_dto.dart';
import '../models/update_account_dto.dart';
import '../models/update_privacy_dto.dart';
import '../models/verify_phone_change_dto.dart';

part 'account_client.g.dart';

@RestApi()
abstract class AccountClient {
  factory AccountClient(Dio dio, {String? baseUrl}) = _AccountClient;

  @GET('/api/v1/me/account')
  Future<GetApiV1MeAccountResponse> getAccount();

  @PATCH('/api/v1/me/account')
  Future<PatchApiV1MeAccountResponse> updateAccount({
    @Body() required UpdateAccountDto body,
  });

  @POST('/api/v1/me/email/change')
  Future<PostApiV1MeEmailChangeResponse> changeEmail({
    @Body() required ChangeEmailDto body,
  });

  @POST('/api/v1/me/phone/change')
  Future<PostApiV1MePhoneChangeResponse> changePhone({
    @Body() required ChangePhoneDto body,
  });

  @POST('/api/v1/me/phone/verify')
  Future<PostApiV1MePhoneVerifyResponse> verifyPhone({
    @Body() required VerifyPhoneChangeDto body,
  });

  @POST('/api/v1/me/password')
  Future<PostApiV1MePasswordResponse> changePassword({
    @Body() required ChangePasswordDto body,
  });

  @GET('/api/v1/me/privacy')
  Future<GetApiV1MePrivacyResponse> getPrivacy();

  @PATCH('/api/v1/me/privacy')
  Future<PatchApiV1MePrivacyResponse> updatePrivacy({
    @Body() required UpdatePrivacyDto body,
  });

  @GET('/api/v1/me/two-step')
  Future<GetApiV1MeTwoStepResponse> getTwoStep();

  @PUT('/api/v1/me/two-step')
  Future<PutApiV1MeTwoStepResponse> setTwoStep({
    @Body() required SetTwoStepDto body,
  });

  @GET('/api/v1/me/export')
  Future<GetApiV1MeExportResponse> exportState();

  @POST('/api/v1/me/export')
  Future<PostApiV1MeExportResponse> requestExport();

  @POST('/api/v1/me/delete')
  Future<PostApiV1MeDeleteResponse> deleteAccount({
    @Body() required DeleteAccountDto body,
  });

  @POST('/api/v1/me/restore')
  Future<PostApiV1MeRestoreResponse> restore();

  @GET('/api/v1/me/membership')
  Future<GetApiV1MeMembershipResponse> getMembership();
}
