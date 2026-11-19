// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_mentorship_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MentorshipHomeResponse _$GetApiV1MentorshipHomeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MentorshipHomeResponse(
  data: MentorshipHomeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MentorshipHomeResponseToJson(
  GetApiV1MentorshipHomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
