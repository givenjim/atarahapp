// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleCardDto _$ArticleCardDtoFromJson(Map<String, dynamic> json) =>
    ArticleCardDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      source: ArticleCardDtoSource.fromJson(json['source'] as String),
      authorName: json['authorName'] as String,
      readMinutes: json['readMinutes'] as num,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      sourceLabel: json['sourceLabel'] as String?,
      heroUrl: json['heroUrl'] as String?,
    );

Map<String, dynamic> _$ArticleCardDtoToJson(ArticleCardDto instance) =>
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
    };
