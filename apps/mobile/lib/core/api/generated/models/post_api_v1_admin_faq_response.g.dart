// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_faq_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminFaqResponse _$PostApiV1AdminFaqResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminFaqResponse(
  data: AdminFaqDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminFaqResponseToJson(
  PostApiV1AdminFaqResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
