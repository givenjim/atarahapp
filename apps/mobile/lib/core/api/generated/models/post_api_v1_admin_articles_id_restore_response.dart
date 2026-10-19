// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_dto.dart';

part 'post_api_v1_admin_articles_id_restore_response.g.dart';

@JsonSerializable()
class PostApiV1AdminArticlesIdRestoreResponse {
  const PostApiV1AdminArticlesIdRestoreResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminArticlesIdRestoreResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminArticlesIdRestoreResponseFromJson(json);

  final AdminArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminArticlesIdRestoreResponseToJson(this);
}
