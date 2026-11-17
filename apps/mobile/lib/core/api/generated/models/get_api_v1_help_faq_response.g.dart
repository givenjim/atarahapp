// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_help_faq_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HelpFaqResponse _$GetApiV1HelpFaqResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HelpFaqResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => FaqDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HelpFaqResponseToJson(
  GetApiV1HelpFaqResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
