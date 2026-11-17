// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_phone_change_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MePhoneChangeResponse _$PostApiV1MePhoneChangeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MePhoneChangeResponse(
  data: ContactChangeStartedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MePhoneChangeResponseToJson(
  PostApiV1MePhoneChangeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
