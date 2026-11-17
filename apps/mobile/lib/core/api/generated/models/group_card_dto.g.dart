// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupCardDto _$GroupCardDtoFromJson(Map<String, dynamic> json) => GroupCardDto(
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
      : GroupCardDtoRole.fromJson(json['role'] as String),
);

Map<String, dynamic> _$GroupCardDtoToJson(GroupCardDto instance) =>
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
    };
