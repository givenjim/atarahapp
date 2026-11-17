// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_legal_documents_id_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLegalDocumentsIdPublishResponse
_$PostApiV1AdminLegalDocumentsIdPublishResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminLegalDocumentsIdPublishResponse(
  data: AdminLegalDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminLegalDocumentsIdPublishResponseToJson(
  PostApiV1AdminLegalDocumentsIdPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
