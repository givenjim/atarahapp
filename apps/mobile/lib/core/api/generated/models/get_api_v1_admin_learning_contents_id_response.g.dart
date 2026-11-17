// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_learning_contents_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLearningContentsIdResponse
_$GetApiV1AdminLearningContentsIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLearningContentsIdResponse(
      data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLearningContentsIdResponseToJson(
  GetApiV1AdminLearningContentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
