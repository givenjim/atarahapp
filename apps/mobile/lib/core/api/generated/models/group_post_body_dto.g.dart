// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_post_body_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupPostBodyDto _$GroupPostBodyDtoFromJson(Map<String, dynamic> json) =>
    GroupPostBodyDto(
      type: PostType.fromJson(json['type'] as String),
      body: json['body'] as String?,
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkUrl: json['linkUrl'] as String?,
    );

Map<String, dynamic> _$GroupPostBodyDtoToJson(GroupPostBodyDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'body': instance.body,
      'mediaIds': instance.mediaIds,
      'linkUrl': instance.linkUrl,
    };
