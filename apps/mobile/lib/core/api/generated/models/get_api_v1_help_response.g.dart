// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_help_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HelpResponse _$GetApiV1HelpResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HelpResponse(
  data: HelpResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HelpResponseToJson(
  GetApiV1HelpResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
