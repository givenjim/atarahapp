// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_api_v1_connections_id_response.dart';
import '../models/get_api_v1_creatives_handle_response.dart';
import '../models/get_api_v1_me_connections_response.dart';
import '../models/get_api_v1_me_growth_response.dart';
import '../models/get_api_v1_me_passport_response.dart';
import '../models/get_api_v1_me_profile_response.dart';
import '../models/list_state.dart';
import '../models/patch_api_v1_me_passport_visibility_response.dart';
import '../models/patch_api_v1_me_profile_response.dart';
import '../models/post_api_v1_connections_id_accept_response.dart';
import '../models/post_api_v1_connections_id_decline_response.dart';
import '../models/post_api_v1_creatives_handle_connect_response.dart';
import '../models/preview_as.dart';
import '../models/set_section_visibility_dto.dart';
import '../models/update_profile_dto.dart';

part 'profile_client.g.dart';

@RestApi()
abstract class ProfileClient {
  factory ProfileClient(Dio dio, {String? baseUrl}) = _ProfileClient;

  @GET('/api/v1/me/profile')
  Future<GetApiV1MeProfileResponse> myProfile();

  @PATCH('/api/v1/me/profile')
  Future<PatchApiV1MeProfileResponse> updateProfile({
    @Body() required UpdateProfileDto body,
  });

  @GET('/api/v1/me/passport')
  Future<GetApiV1MePassportResponse> myPassport();

  @PATCH('/api/v1/me/passport/visibility')
  Future<PatchApiV1MePassportVisibilityResponse> setVisibility({
    @Body() required SetSectionVisibilityDto body,
  });

  @GET('/api/v1/me/growth')
  Future<GetApiV1MeGrowthResponse> myGrowth();

  /// [previewAs] - Owner only: see the profile as the public or as other members do.
  @GET('/api/v1/creatives/{handle}')
  Future<GetApiV1CreativesHandleResponse> creative({
    @Path('handle') required String handle,
    @Query('previewAs') PreviewAs? previewAs,
  });

  @POST('/api/v1/creatives/{handle}/connect')
  Future<PostApiV1CreativesHandleConnectResponse> connect({
    @Path('handle') required String handle,
  });

  @POST('/api/v1/connections/{id}/accept')
  Future<PostApiV1ConnectionsIdAcceptResponse> accept({
    @Path('id') required String id,
  });

  @POST('/api/v1/connections/{id}/decline')
  Future<PostApiV1ConnectionsIdDeclineResponse> decline({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/connections/{id}')
  Future<DeleteApiV1ConnectionsIdResponse> removeConnection({
    @Path('id') required String id,
  });

  @GET('/api/v1/me/connections')
  Future<GetApiV1MeConnectionsResponse> myConnections({
    @Query('listState') ListState? listState = ListState.connected,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
