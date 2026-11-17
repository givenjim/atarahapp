// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_help_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminHelpArticleDto _$AdminHelpArticleDtoFromJson(Map<String, dynamic> json) =>
    AdminHelpArticleDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => HelpBlockDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sortOrder: json['sortOrder'] as num,
      published: json['published'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdminHelpArticleDtoToJson(
  AdminHelpArticleDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'summary': instance.summary,
  'blocks': instance.blocks,
  'sortOrder': instance.sortOrder,
  'published': instance.published,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
