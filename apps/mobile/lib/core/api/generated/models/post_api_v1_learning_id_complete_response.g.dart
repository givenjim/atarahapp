// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_learning_id_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1LearningIdCompleteResponse
_$PostApiV1LearningIdCompleteResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1LearningIdCompleteResponse(
      data: LearningItemProgressDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1LearningIdCompleteResponseToJson(
  PostApiV1LearningIdCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
