// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_users_id_overview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminUsersIdOverviewResponse
_$GetApiV1AdminUsersIdOverviewResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminUsersIdOverviewResponse(
      data: AdminUserOverviewDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminUsersIdOverviewResponseToJson(
  GetApiV1AdminUsersIdOverviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
