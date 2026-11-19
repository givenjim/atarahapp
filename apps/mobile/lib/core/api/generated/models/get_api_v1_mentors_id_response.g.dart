// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_mentors_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MentorsIdResponse _$GetApiV1MentorsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MentorsIdResponse(
  data: MentorDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MentorsIdResponseToJson(
  GetApiV1MentorsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
