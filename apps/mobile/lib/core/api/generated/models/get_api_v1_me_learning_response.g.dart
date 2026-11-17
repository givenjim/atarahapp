// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_learning_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeLearningResponse _$GetApiV1MeLearningResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeLearningResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => MyLearningItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeLearningResponseToJson(
  GetApiV1MeLearningResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
