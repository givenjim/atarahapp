// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_legal_documents_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLegalDocumentsResponse
_$PostApiV1AdminLegalDocumentsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminLegalDocumentsResponse(
      data: AdminLegalDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminLegalDocumentsResponseToJson(
  PostApiV1AdminLegalDocumentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
