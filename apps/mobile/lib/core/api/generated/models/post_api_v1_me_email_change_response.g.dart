// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_email_change_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeEmailChangeResponse _$PostApiV1MeEmailChangeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeEmailChangeResponse(
  data: ContactChangeStartedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeEmailChangeResponseToJson(
  PostApiV1MeEmailChangeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
