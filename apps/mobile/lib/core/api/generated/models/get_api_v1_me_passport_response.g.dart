// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_passport_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MePassportResponse _$GetApiV1MePassportResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MePassportResponse(
  data: PassportDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MePassportResponseToJson(
  GetApiV1MePassportResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
