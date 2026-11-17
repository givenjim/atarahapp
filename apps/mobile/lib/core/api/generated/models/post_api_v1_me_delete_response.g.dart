// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_delete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeDeleteResponse _$PostApiV1MeDeleteResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeDeleteResponse(
  data: DeletionStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeDeleteResponseToJson(
  PostApiV1MeDeleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
