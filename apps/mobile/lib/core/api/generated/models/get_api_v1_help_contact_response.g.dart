// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_help_contact_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HelpContactResponse _$GetApiV1HelpContactResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HelpContactResponse(
  data: HelpContactDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HelpContactResponseToJson(
  GetApiV1HelpContactResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
