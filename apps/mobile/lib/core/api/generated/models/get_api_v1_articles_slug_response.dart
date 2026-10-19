// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_dto.dart';

part 'get_api_v1_articles_slug_response.g.dart';

@JsonSerializable()
class GetApiV1ArticlesSlugResponse {
  const GetApiV1ArticlesSlugResponse({required this.data, this.meta});

  factory GetApiV1ArticlesSlugResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1ArticlesSlugResponseFromJson(json);

  final ArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1ArticlesSlugResponseToJson(this);
}
