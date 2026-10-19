// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishArticleDto _$PublishArticleDtoFromJson(Map<String, dynamic> json) =>
    PublishArticleDto(
      publishAt: json['publishAt'] == null
          ? null
          : DateTime.parse(json['publishAt'] as String),
    );

Map<String, dynamic> _$PublishArticleDtoToJson(PublishArticleDto instance) =>
    <String, dynamic>{'publishAt': instance.publishAt?.toIso8601String()};
