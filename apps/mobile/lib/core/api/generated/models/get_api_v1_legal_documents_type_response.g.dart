// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_legal_documents_type_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LegalDocumentsTypeResponse _$GetApiV1LegalDocumentsTypeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LegalDocumentsTypeResponse(
  data: LegalFullDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LegalDocumentsTypeResponseToJson(
  GetApiV1LegalDocumentsTypeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
