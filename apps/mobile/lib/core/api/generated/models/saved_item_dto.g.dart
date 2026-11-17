// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedItemDto _$SavedItemDtoFromJson(Map<String, dynamic> json) => SavedItemDto(
  type: SavedKind.fromJson(json['type'] as String),
  targetId: json['targetId'] as String,
  savedAt: DateTime.parse(json['savedAt'] as String),
  title: json['title'] as String,
  path: json['path'] as String,
  collection: json['collection'] as String?,
  subtitle: json['subtitle'] as String?,
  imageUrl: json['imageUrl'] as String?,
  article: json['article'] == null
      ? null
      : ArticleCardDto.fromJson(json['article'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SavedItemDtoToJson(SavedItemDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'targetId': instance.targetId,
      'savedAt': instance.savedAt.toIso8601String(),
      'collection': instance.collection,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'path': instance.path,
      'article': instance.article,
    };
