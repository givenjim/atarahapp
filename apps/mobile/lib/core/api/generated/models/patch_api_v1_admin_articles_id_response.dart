// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_dto.dart';

part 'patch_api_v1_admin_articles_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminArticlesIdResponse {
  const PatchApiV1AdminArticlesIdResponse({required this.data, this.meta});

  factory PatchApiV1AdminArticlesIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1AdminArticlesIdResponseFromJson(json);

  final AdminArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1AdminArticlesIdResponseToJson(this);
}
