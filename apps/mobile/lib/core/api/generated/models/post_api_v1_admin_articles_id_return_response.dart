// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_dto.dart';

part 'post_api_v1_admin_articles_id_return_response.g.dart';

@JsonSerializable()
class PostApiV1AdminArticlesIdReturnResponse {
  const PostApiV1AdminArticlesIdReturnResponse({required this.data, this.meta});

  factory PostApiV1AdminArticlesIdReturnResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminArticlesIdReturnResponseFromJson(json);

  final AdminArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminArticlesIdReturnResponseToJson(this);
}
