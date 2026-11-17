// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_legal_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LegalResponse _$GetApiV1LegalResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LegalResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => LegalSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LegalResponseToJson(
  GetApiV1LegalResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
