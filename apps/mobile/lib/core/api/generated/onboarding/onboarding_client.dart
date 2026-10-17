// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_api_v1_me_avatar_response.dart';
import '../models/get_api_v1_handles_handle_availability_response.dart';
import '../models/get_api_v1_me_onboarding_response.dart';
import '../models/patch_api_v1_me_onboarding_response.dart';
import '../models/post_api_v1_me_avatar_response.dart';
import '../models/post_api_v1_me_onboarding_complete_response.dart';
import '../models/save_onboarding_step_dto.dart';
import '../models/set_avatar_dto.dart';

part 'onboarding_client.g.dart';

@RestApi()
abstract class OnboardingClient {
  factory OnboardingClient(Dio dio, {String? baseUrl}) = _OnboardingClient;

  @GET('/api/v1/me/onboarding')
  Future<GetApiV1MeOnboardingResponse> state();

  @PATCH('/api/v1/me/onboarding')
  Future<PatchApiV1MeOnboardingResponse> saveStep({
    @Body() required SaveOnboardingStepDto body,
  });

  @POST('/api/v1/me/onboarding/complete')
  Future<PostApiV1MeOnboardingCompleteResponse> completeOnboarding();

  @POST('/api/v1/me/avatar')
  Future<PostApiV1MeAvatarResponse> setAvatar({
    @Body() required SetAvatarDto body,
  });

  @DELETE('/api/v1/me/avatar')
  Future<DeleteApiV1MeAvatarResponse> removeAvatar();

  @GET('/api/v1/handles/{handle}/availability')
  Future<GetApiV1HandlesHandleAvailabilityResponse> availability({
    @Path('handle') required String handle,
  });
}
