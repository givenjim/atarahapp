// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/assign_role_dto.dart';
import '../models/delete_api_v1_admin_users_id_roles_role_response.dart';
import '../models/get_api_v1_admin_analytics_events_response.dart';
import '../models/get_api_v1_admin_dashboard_response.dart';
import '../models/get_api_v1_admin_jobs_queue_failed_response.dart';
import '../models/get_api_v1_admin_jobs_response.dart';
import '../models/get_api_v1_admin_roles_response.dart';
import '../models/get_api_v1_admin_users_id_overview_response.dart';
import '../models/post_api_v1_admin_users_id_roles_response.dart';

part 'admin_operations_client.g.dart';

@RestApi()
abstract class AdminOperationsClient {
  factory AdminOperationsClient(Dio dio, {String? baseUrl}) = _AdminOperationsClient;

  @GET('/api/v1/admin/dashboard')
  Future<GetApiV1AdminDashboardResponse> dashboard();

  /// [from] - First Nairobi date. Default: 29 days ago.
  ///
  /// [to] - Last Nairobi date. Default: today. At most 120 days.
  ///
  /// [names] - Event names (comma separated). Default: all.
  @GET('/api/v1/admin/analytics/events')
  Future<GetApiV1AdminAnalyticsEventsResponse> analytics({
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('names') List<String>? names,
  });

  @GET('/api/v1/admin/jobs')
  Future<GetApiV1AdminJobsResponse> jobs();

  @GET('/api/v1/admin/jobs/{queue}/failed')
  Future<GetApiV1AdminJobsQueueFailedResponse> failedJobs({
    @Path('queue') required String queue,
  });

  @POST('/api/v1/admin/jobs/{queue}/{jobId}/retry')
  Future<void> retry({
    @Path('queue') required String queue,
    @Path('jobId') required String jobId,
  });

  @GET('/api/v1/admin/roles')
  Future<GetApiV1AdminRolesResponse> roles();

  @GET('/api/v1/admin/users/{id}/overview')
  Future<GetApiV1AdminUsersIdOverviewResponse> overview({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/users/{id}/roles')
  Future<PostApiV1AdminUsersIdRolesResponse> assignRole({
    @Path('id') required String id,
    @Body() required AssignRoleDto body,
  });

  @DELETE('/api/v1/admin/users/{id}/roles/{role}')
  Future<DeleteApiV1AdminUsersIdRolesRoleResponse> revokeRole({
    @Path('id') required String id,
    @Path('role') required String role,
    @Query('reason') String? reason,
  });
}
