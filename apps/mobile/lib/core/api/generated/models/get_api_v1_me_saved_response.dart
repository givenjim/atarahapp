// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'saved_article_dto.dart';

part 'get_api_v1_me_saved_response.g.dart';

@JsonSerializable()
class GetApiV1MeSavedResponse {
  const GetApiV1MeSavedResponse({required this.data, this.meta});

  factory GetApiV1MeSavedResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeSavedResponseFromJson(json);

  final List<SavedArticleDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeSavedResponseToJson(this);
}
