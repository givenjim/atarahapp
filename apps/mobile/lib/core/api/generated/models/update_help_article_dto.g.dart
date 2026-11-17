// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_help_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHelpArticleDto _$UpdateHelpArticleDtoFromJson(
  Map<String, dynamic> json,
) => UpdateHelpArticleDto(
  title: json['title'] as String?,
  summary: json['summary'] as String?,
  blocks: (json['blocks'] as List<dynamic>?)
      ?.map((e) => ArticleBlockInputDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  sortOrder: json['sortOrder'] as num?,
  published: json['published'] as bool?,
);

Map<String, dynamic> _$UpdateHelpArticleDtoToJson(
  UpdateHelpArticleDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'summary': instance.summary,
  'blocks': instance.blocks,
  'sortOrder': instance.sortOrder,
  'published': instance.published,
};
