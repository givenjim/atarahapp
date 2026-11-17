// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_learning_contents_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLearningContentsResponse
_$GetApiV1AdminLearningContentsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLearningContentsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminContentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLearningContentsResponseToJson(
  GetApiV1AdminLearningContentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
