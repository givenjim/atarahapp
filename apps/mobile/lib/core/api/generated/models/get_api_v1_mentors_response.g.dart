// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_mentors_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MentorsResponse _$GetApiV1MentorsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MentorsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => MentorCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MentorsResponseToJson(
  GetApiV1MentorsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
