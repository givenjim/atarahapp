// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_legal_type_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LegalTypeResponse _$GetApiV1LegalTypeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LegalTypeResponse(
  data: LegalDocumentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LegalTypeResponseToJson(
  GetApiV1LegalTypeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
