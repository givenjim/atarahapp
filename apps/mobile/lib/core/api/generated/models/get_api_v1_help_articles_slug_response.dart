// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_article_dto.dart';

part 'get_api_v1_help_articles_slug_response.g.dart';

@JsonSerializable()
class GetApiV1HelpArticlesSlugResponse {
  const GetApiV1HelpArticlesSlugResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1HelpArticlesSlugResponse.fromJson(Map<String, Object?> json) => _$GetApiV1HelpArticlesSlugResponseFromJson(json);
  
  final HelpArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1HelpArticlesSlugResponseToJson(this);
}
