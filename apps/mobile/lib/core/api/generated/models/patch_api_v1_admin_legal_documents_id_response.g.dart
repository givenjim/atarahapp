// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_legal_documents_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminLegalDocumentsIdResponse
_$PatchApiV1AdminLegalDocumentsIdResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminLegalDocumentsIdResponse(
      data: AdminLegalDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminLegalDocumentsIdResponseToJson(
  PatchApiV1AdminLegalDocumentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
