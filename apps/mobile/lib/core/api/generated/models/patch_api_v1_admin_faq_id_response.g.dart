// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_faq_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminFaqIdResponse _$PatchApiV1AdminFaqIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminFaqIdResponse(
  data: AdminFaqDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminFaqIdResponseToJson(
  PatchApiV1AdminFaqIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
