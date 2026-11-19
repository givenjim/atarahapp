// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_mentor_application_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMentorApplicationResponse
_$GetApiV1MeMentorApplicationResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeMentorApplicationResponse(
      data: MyApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeMentorApplicationResponseToJson(
  GetApiV1MeMentorApplicationResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
