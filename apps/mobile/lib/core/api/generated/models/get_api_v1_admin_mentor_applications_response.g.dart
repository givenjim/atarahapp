// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_mentor_applications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMentorApplicationsResponse
_$GetApiV1AdminMentorApplicationsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMentorApplicationsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminApplicationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMentorApplicationsResponseToJson(
  GetApiV1AdminMentorApplicationsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
