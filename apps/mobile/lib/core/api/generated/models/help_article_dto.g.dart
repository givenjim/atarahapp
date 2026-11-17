// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpArticleDto _$HelpArticleDtoFromJson(Map<String, dynamic> json) =>
    HelpArticleDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => HelpBlockDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HelpArticleDtoToJson(HelpArticleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'summary': instance.summary,
      'blocks': instance.blocks,
    };
