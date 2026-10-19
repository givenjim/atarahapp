// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateArticleDto _$UpdateArticleDtoFromJson(Map<String, dynamic> json) =>
    UpdateArticleDto(
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      authorName: json['authorName'] as String?,
      source: json['source'] == null
          ? null
          : UpdateArticleDtoSource.fromJson(json['source'] as String),
      sourceLabel: json['sourceLabel'] as String?,
      heroMediaId: json['heroMediaId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      blocks: (json['blocks'] as List<dynamic>?)
          ?.map((e) => ArticleBlockInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateArticleDtoToJson(UpdateArticleDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'summary': instance.summary,
      'authorName': instance.authorName,
      'source': instance.source,
      'sourceLabel': instance.sourceLabel,
      'heroMediaId': instance.heroMediaId,
      'tags': instance.tags,
      'blocks': instance.blocks,
    };
