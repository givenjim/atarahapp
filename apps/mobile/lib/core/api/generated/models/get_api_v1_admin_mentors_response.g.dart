// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_mentors_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMentorsResponse _$GetApiV1AdminMentorsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminMentorsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminMentorDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminMentorsResponseToJson(
  GetApiV1AdminMentorsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
