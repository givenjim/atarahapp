// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_reports_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminReportsResponse _$GetApiV1AdminReportsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminReportsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminReportDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminReportsResponseToJson(
  GetApiV1AdminReportsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
