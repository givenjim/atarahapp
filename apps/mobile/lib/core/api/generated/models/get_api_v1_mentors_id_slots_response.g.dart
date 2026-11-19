// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_mentors_id_slots_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MentorsIdSlotsResponse _$GetApiV1MentorsIdSlotsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MentorsIdSlotsResponse(
  data: SlotsDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MentorsIdSlotsResponseToJson(
  GetApiV1MentorsIdSlotsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
