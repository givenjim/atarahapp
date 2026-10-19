// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'search_result_dto.dart';

part 'get_api_v1_search_response.g.dart';

@JsonSerializable()
class GetApiV1SearchResponse {
  const GetApiV1SearchResponse({required this.data, this.meta});

  factory GetApiV1SearchResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1SearchResponseFromJson(json);

  final SearchResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1SearchResponseToJson(this);
}
