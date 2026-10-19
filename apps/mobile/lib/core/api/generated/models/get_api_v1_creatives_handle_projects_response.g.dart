// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_projects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleProjectsResponse
_$GetApiV1CreativesHandleProjectsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1CreativesHandleProjectsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ProjectCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1CreativesHandleProjectsResponseToJson(
  GetApiV1CreativesHandleProjectsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
