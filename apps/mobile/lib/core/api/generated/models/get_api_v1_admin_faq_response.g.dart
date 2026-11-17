// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_faq_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminFaqResponse _$GetApiV1AdminFaqResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminFaqResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminFaqDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminFaqResponseToJson(
  GetApiV1AdminFaqResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
