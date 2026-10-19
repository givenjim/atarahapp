// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_hit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHitDto _$SearchHitDtoFromJson(Map<String, dynamic> json) => SearchHitDto(
  type: SearchHitDtoType.fromJson(json['type'] as String),
  id: json['id'] as String,
  title: json['title'] as String,
  verified: json['verified'] as bool,
  path: json['path'] as String,
  subtitle: json['subtitle'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$SearchHitDtoToJson(SearchHitDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'verified': instance.verified,
      'path': instance.path,
    };
