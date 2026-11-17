// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_reports_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeReportsResponse _$GetApiV1MeReportsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeReportsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => MyReportDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeReportsResponseToJson(
  GetApiV1MeReportsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
