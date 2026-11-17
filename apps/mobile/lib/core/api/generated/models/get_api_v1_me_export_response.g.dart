// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_export_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeExportResponse _$GetApiV1MeExportResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeExportResponse(
  data: ExportStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeExportResponseToJson(
  GetApiV1MeExportResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
