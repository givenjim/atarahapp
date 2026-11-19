// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_help_article_dto.dart';

part 'patch_api_v1_admin_help_articles_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminHelpArticlesIdResponse {
  const PatchApiV1AdminHelpArticlesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminHelpArticlesIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminHelpArticlesIdResponseFromJson(json);
  
  final AdminHelpArticleDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminHelpArticlesIdResponseToJson(this);
}
