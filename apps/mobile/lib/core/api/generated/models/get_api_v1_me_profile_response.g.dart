// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeProfileResponse _$GetApiV1MeProfileResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeProfileResponse(
  data: OwnProfileDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeProfileResponseToJson(
  GetApiV1MeProfileResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
