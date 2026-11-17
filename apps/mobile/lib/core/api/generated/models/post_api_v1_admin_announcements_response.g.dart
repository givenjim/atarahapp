// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_announcements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAnnouncementsResponse
_$PostApiV1AdminAnnouncementsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminAnnouncementsResponse(
      data: PostViewDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminAnnouncementsResponseToJson(
  PostApiV1AdminAnnouncementsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
