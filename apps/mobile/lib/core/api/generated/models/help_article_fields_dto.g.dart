// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_article_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpArticleFieldsDto _$HelpArticleFieldsDtoFromJson(
  Map<String, dynamic> json,
) => HelpArticleFieldsDto(
  slug: json['slug'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  blocks: (json['blocks'] as List<dynamic>?)
      ?.map((e) => ArticleBlockInputDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  sortOrder: json['sortOrder'] as num?,
  published: json['published'] as bool?,
);

Map<String, dynamic> _$HelpArticleFieldsDtoToJson(
  HelpArticleFieldsDto instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'summary': instance.summary,
  'blocks': instance.blocks,
  'sortOrder': instance.sortOrder,
  'published': instance.published,
};
