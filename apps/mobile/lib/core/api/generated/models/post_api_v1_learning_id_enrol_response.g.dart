// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_learning_id_enrol_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1LearningIdEnrolResponse _$PostApiV1LearningIdEnrolResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1LearningIdEnrolResponse(
  data: EnrolmentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1LearningIdEnrolResponseToJson(
  PostApiV1LearningIdEnrolResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
