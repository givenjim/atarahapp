// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleDto _$ArticleDtoFromJson(Map<String, dynamic> json) => ArticleDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String,
  source: ArticleDtoSource.fromJson(json['source'] as String),
  authorName: json['authorName'] as String,
  readMinutes: json['readMinutes'] as num,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  blocks: (json['blocks'] as List<dynamic>)
      .map((e) => ArticleBlockDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  saved: json['saved'] as bool,
  shareUrl: json['shareUrl'] as String,
  sourceLabel: json['sourceLabel'] as String?,
  heroUrl: json['heroUrl'] as String?,
);

Map<String, dynamic> _$ArticleDtoToJson(ArticleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'summary': instance.summary,
      'source': instance.source,
      'sourceLabel': instance.sourceLabel,
      'authorName': instance.authorName,
      'readMinutes': instance.readMinutes,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'heroUrl': instance.heroUrl,
      'tags': instance.tags,
      'blocks': instance.blocks,
      'saved': instance.saved,
      'shareUrl': instance.shareUrl,
    };
