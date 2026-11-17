// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningIdResponse _$GetApiV1LearningIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LearningIdResponse(
  data: LearningDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LearningIdResponseToJson(
  GetApiV1LearningIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
