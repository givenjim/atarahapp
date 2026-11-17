// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'saved_counts_dto.dart';

part 'get_api_v1_me_saved_counts_response.g.dart';

@JsonSerializable()
class GetApiV1MeSavedCountsResponse {
  const GetApiV1MeSavedCountsResponse({required this.data, this.meta});

  factory GetApiV1MeSavedCountsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeSavedCountsResponseFromJson(json);

  final SavedCountsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeSavedCountsResponseToJson(this);
}
