// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningResponse _$GetApiV1LearningResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LearningResponse(
  data: LearningHubDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LearningResponseToJson(
  GetApiV1LearningResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
