// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_dto.dart';

part 'post_api_v1_admin_articles_id_publish_response.g.dart';

@JsonSerializable()
class PostApiV1AdminArticlesIdPublishResponse {
  const PostApiV1AdminArticlesIdPublishResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminArticlesIdPublishResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminArticlesIdPublishResponseFromJson(json);

  final AdminArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminArticlesIdPublishResponseToJson(this);
}
