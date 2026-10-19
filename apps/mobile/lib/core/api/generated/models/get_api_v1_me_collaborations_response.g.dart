// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_collaborations_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCollaborationsResponse _$GetApiV1MeCollaborationsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCollaborationsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CollaborationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCollaborationsResponseToJson(
  GetApiV1MeCollaborationsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
