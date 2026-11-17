// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_help_article_dto.dart';

part 'post_api_v1_admin_help_articles_response.g.dart';

@JsonSerializable()
class PostApiV1AdminHelpArticlesResponse {
  const PostApiV1AdminHelpArticlesResponse({required this.data, this.meta});

  factory PostApiV1AdminHelpArticlesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminHelpArticlesResponseFromJson(json);

  final AdminHelpArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminHelpArticlesResponseToJson(this);
}
