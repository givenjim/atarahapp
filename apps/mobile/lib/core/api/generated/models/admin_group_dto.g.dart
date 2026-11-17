// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminGroupDto _$AdminGroupDtoFromJson(Map<String, dynamic> json) =>
    AdminGroupDto(
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
          : AdminGroupDtoRole.fromJson(json['role'] as String),
      visibility: GroupVisibility.fromJson(json['visibility'] as String),
      disciplineId: json['disciplineId'] as String?,
      countyId: json['countyId'] as String?,
      coverMediaId: json['coverMediaId'] as String?,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      moderators: (json['moderators'] as List<dynamic>)
          .map(
            (e) => AdminGroupModeratorDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      pinnedPostIds: (json['pinnedPostIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminGroupDtoToJson(AdminGroupDto instance) =>
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
      'disciplineId': instance.disciplineId,
      'countyId': instance.countyId,
      'coverMediaId': instance.coverMediaId,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'moderators': instance.moderators,
      'pinnedPostIds': instance.pinnedPostIds,
      'createdAt': instance.createdAt.toIso8601String(),
    };
