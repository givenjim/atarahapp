// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedArticleDto _$SavedArticleDtoFromJson(Map<String, dynamic> json) =>
    SavedArticleDto(
      savedAt: DateTime.parse(json['savedAt'] as String),
      article: ArticleCardDto.fromJson(json['article'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavedArticleDtoToJson(SavedArticleDto instance) =>
    <String, dynamic>{
      'savedAt': instance.savedAt.toIso8601String(),
      'article': instance.article,
    };
