// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_restore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeRestoreResponse _$PostApiV1MeRestoreResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeRestoreResponse(
  data: RestoredDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeRestoreResponseToJson(
  PostApiV1MeRestoreResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
