// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupDetailDto _$GroupDetailDtoFromJson(Map<String, dynamic> json) =>
    GroupDetailDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      type: GroupType.fromJson(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String?,
      memberCount: json['memberCount'] as num,
      isOfficial: json['isOfficial'] as bool,
      focus: json['focus'] as String?,
      joined: json['joined'] as bool,
      role: json['role'] == null
          ? null
          : GroupDetailDtoRole.fromJson(json['role'] as String),
      visibility: GroupVisibility.fromJson(json['visibility'] as String),
      pinned: json['pinned'] == null
          ? null
          : PostViewDto.fromJson(json['pinned'] as Map<String, dynamic>),
      recentDiscussions: (json['recentDiscussions'] as List<dynamic>)
          .map((e) => PostViewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      viewer: GroupViewerDto.fromJson(json['viewer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupDetailDtoToJson(GroupDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'memberCount': instance.memberCount,
      'isOfficial': instance.isOfficial,
      'focus': instance.focus,
      'joined': instance.joined,
      'role': instance.role,
      'visibility': instance.visibility,
      'pinned': instance.pinned,
      'recentDiscussions': instance.recentDiscussions,
      'viewer': instance.viewer,
    };
