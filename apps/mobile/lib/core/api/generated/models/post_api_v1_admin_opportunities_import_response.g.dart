// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_import_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesImportResponse
_$PostApiV1AdminOpportunitiesImportResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesImportResponse(
  data: ImportCommitResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesImportResponseToJson(
  PostApiV1AdminOpportunitiesImportResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
