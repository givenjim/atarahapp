// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) =>
    CreatePostDto(
      type: PostType.fromJson(json['type'] as String),
      audience: json['audience'] == null
          ? PostAudience.members
          : PostAudience.fromJson(json['audience'] as String),
      body: json['body'] as String?,
      groupId: json['groupId'] as String?,
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkUrl: json['linkUrl'] as String?,
    );

Map<String, dynamic> _$CreatePostDtoToJson(CreatePostDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'body': instance.body,
      'audience': instance.audience,
      'groupId': instance.groupId,
      'mediaIds': instance.mediaIds,
      'linkUrl': instance.linkUrl,
    };
