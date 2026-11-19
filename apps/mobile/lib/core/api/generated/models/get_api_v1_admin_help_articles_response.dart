// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_help_article_dto.dart';

part 'get_api_v1_admin_help_articles_response.g.dart';

@JsonSerializable()
class GetApiV1AdminHelpArticlesResponse {
  const GetApiV1AdminHelpArticlesResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminHelpArticlesResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminHelpArticlesResponseFromJson(json);
  
  final List<AdminHelpArticleDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminHelpArticlesResponseToJson(this);
}
