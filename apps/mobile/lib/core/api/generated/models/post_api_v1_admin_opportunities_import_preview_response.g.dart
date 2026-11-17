// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_import_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesImportPreviewResponse
_$PostApiV1AdminOpportunitiesImportPreviewResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesImportPreviewResponse(
  data: ImportReportDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesImportPreviewResponseToJson(
  PostApiV1AdminOpportunitiesImportPreviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
