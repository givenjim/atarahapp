// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'recent_search_dto.dart';

part 'get_api_v1_me_recent_searches_response.g.dart';

@JsonSerializable()
class GetApiV1MeRecentSearchesResponse {
  const GetApiV1MeRecentSearchesResponse({required this.data, this.meta});

  factory GetApiV1MeRecentSearchesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1MeRecentSearchesResponseFromJson(json);

  final List<RecentSearchDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1MeRecentSearchesResponseToJson(this);
}
