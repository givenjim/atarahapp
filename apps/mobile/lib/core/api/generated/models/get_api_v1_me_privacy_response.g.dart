// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_privacy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MePrivacyResponse _$GetApiV1MePrivacyResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MePrivacyResponse(
  data: PrivacyDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MePrivacyResponseToJson(
  GetApiV1MePrivacyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
