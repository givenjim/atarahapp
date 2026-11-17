// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_phone_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MePhoneVerifyResponse _$PostApiV1MePhoneVerifyResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MePhoneVerifyResponse(
  data: AccountDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MePhoneVerifyResponseToJson(
  PostApiV1MePhoneVerifyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
