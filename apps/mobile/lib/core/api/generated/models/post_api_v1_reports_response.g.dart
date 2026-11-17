// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_reports_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1ReportsResponse _$PostApiV1ReportsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1ReportsResponse(
  data: MyReportDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1ReportsResponseToJson(
  PostApiV1ReportsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
