// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_mentor_session_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMentorSessionTypesResponse
_$GetApiV1AdminMentorSessionTypesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMentorSessionTypesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminSessionTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMentorSessionTypesResponseToJson(
  GetApiV1AdminMentorSessionTypesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
