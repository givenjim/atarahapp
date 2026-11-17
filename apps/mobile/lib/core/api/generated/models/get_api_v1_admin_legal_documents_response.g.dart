// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_legal_documents_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLegalDocumentsResponse
_$GetApiV1AdminLegalDocumentsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLegalDocumentsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminLegalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLegalDocumentsResponseToJson(
  GetApiV1AdminLegalDocumentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
