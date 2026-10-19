// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateArticleDto _$CreateArticleDtoFromJson(Map<String, dynamic> json) =>
    CreateArticleDto(
      title: json['title'] as String,
      authorName: json['authorName'] as String,
    );

Map<String, dynamic> _$CreateArticleDtoToJson(CreateArticleDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'authorName': instance.authorName,
    };
