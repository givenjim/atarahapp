// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_article_list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminArticleListItemDto _$AdminArticleListItemDtoFromJson(
  Map<String, dynamic> json,
) => AdminArticleListItemDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  authorName: json['authorName'] as String,
  status: AdminArticleListItemDtoStatus.fromJson(json['status'] as String),
  source: AdminArticleListItemDtoSource.fromJson(json['source'] as String),
  scheduled: json['scheduled'] as bool,
  featured: json['featured'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$AdminArticleListItemDtoToJson(
  AdminArticleListItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'authorName': instance.authorName,
  'status': instance.status,
  'source': instance.source,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'scheduled': instance.scheduled,
  'featured': instance.featured,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
