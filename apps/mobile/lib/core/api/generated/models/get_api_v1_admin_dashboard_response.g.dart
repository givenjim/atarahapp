// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminDashboardResponse _$GetApiV1AdminDashboardResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminDashboardResponse(
  data: DashboardDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminDashboardResponseToJson(
  GetApiV1AdminDashboardResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
