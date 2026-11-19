// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_mentor_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMentorResponse _$GetApiV1MeMentorResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeMentorResponse(
  data: MyMentorDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeMentorResponseToJson(
  GetApiV1MeMentorResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
