// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_admin_audit_logs_response.dart';
import '../models/get_api_v1_admin_users_id_response.dart';
import '../models/get_api_v1_admin_users_response.dart';
import '../models/post_api_v1_admin_users_id_reactivate_response.dart';
import '../models/post_api_v1_admin_users_id_suspend_response.dart';
import '../models/reactivate_user_dto.dart';
import '../models/status.dart';
import '../models/suspend_user_dto.dart';

part 'admin_client.g.dart';

@RestApi()
abstract class AdminClient {
  factory AdminClient(Dio dio, {String? baseUrl}) = _AdminClient;

  /// [q] - Matches name, email or phone.
  @GET('/api/v1/admin/users')
  Future<GetApiV1AdminUsersResponse> users({
    @Query('q') String? q,
    @Query('status') Status? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/users/{id}')
  Future<GetApiV1AdminUsersIdResponse> user({@Path('id') required String id});

  @POST('/api/v1/admin/users/{id}/suspend')
  Future<PostApiV1AdminUsersIdSuspendResponse> suspend({
    @Path('id') required String id,
    @Body() required SuspendUserDto body,
  });

  @POST('/api/v1/admin/users/{id}/reactivate')
  Future<PostApiV1AdminUsersIdReactivateResponse> reactivate({
    @Path('id') required String id,
    @Body() required ReactivateUserDto body,
  });

  /// [action] - Exact action, e.g. user.suspend.
  @GET('/api/v1/admin/audit-logs')
  Future<GetApiV1AdminAuditLogsResponse> audit({
    @Query('action') String? action,
    @Query('entityType') String? entityType,
    @Query('entityId') String? entityId,
    @Query('actorId') String? actorId,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
