// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_export_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeExportResponse _$PostApiV1MeExportResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeExportResponse(
  data: ExportStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeExportResponseToJson(
  PostApiV1MeExportResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
