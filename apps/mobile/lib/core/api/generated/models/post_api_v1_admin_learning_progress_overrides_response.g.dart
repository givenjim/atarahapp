// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_progress_overrides_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningProgressOverridesResponse
_$PostApiV1AdminLearningProgressOverridesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminLearningProgressOverridesResponse(
  data: OverrideResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminLearningProgressOverridesResponseToJson(
  PostApiV1AdminLearningProgressOverridesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
