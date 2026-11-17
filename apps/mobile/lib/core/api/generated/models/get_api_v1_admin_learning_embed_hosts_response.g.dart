// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_learning_embed_hosts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLearningEmbedHostsResponse
_$GetApiV1AdminLearningEmbedHostsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLearningEmbedHostsResponse(
      data: EmbedHostsDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLearningEmbedHostsResponseToJson(
  GetApiV1AdminLearningEmbedHostsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
