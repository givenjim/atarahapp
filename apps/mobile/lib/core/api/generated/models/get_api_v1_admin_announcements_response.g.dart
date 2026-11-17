// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_announcements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminAnnouncementsResponse _$GetApiV1AdminAnnouncementsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminAnnouncementsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => PostViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminAnnouncementsResponseToJson(
  GetApiV1AdminAnnouncementsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
