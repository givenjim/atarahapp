// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostViewDto _$PostViewDtoFromJson(Map<String, dynamic> json) => PostViewDto(
  id: json['id'] as String,
  type: PostType.fromJson(json['type'] as String),
  body: json['body'] as String,
  audience: PostAudience.fromJson(json['audience'] as String),
  group: json['group'] == null
      ? null
      : PostGroupRefDto.fromJson(json['group'] as Map<String, dynamic>),
  author: PostAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  media: (json['media'] as List<dynamic>)
      .map((e) => PostMediaItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  link: json['link'] == null
      ? null
      : PostLinkPreviewDto.fromJson(json['link'] as Map<String, dynamic>),
  reactionCount: json['reactionCount'] as num,
  replyCount: json['replyCount'] as num,
  isStaffAnnouncement: json['isStaffAnnouncement'] as bool,
  status: PostViewStatus.fromJson(json['status'] as String),
  viewer: PostViewerDto.fromJson(json['viewer'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
);

Map<String, dynamic> _$PostViewDtoToJson(PostViewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'body': instance.body,
      'audience': instance.audience,
      'group': instance.group,
      'author': instance.author,
      'media': instance.media,
      'link': instance.link,
      'reactionCount': instance.reactionCount,
      'replyCount': instance.replyCount,
      'isStaffAnnouncement': instance.isStaffAnnouncement,
      'status': instance.status,
      'viewer': instance.viewer,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
    };
