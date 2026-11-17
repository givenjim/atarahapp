// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_article_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpArticleCardDto _$HelpArticleCardDtoFromJson(Map<String, dynamic> json) =>
    HelpArticleCardDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$HelpArticleCardDtoToJson(HelpArticleCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'summary': instance.summary,
    };
