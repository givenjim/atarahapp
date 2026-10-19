// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'search_group_dto.dart';

part 'search_result_dto.g.dart';

@JsonSerializable()
class SearchResultDto {
  const SearchResultDto({required this.query, required this.groups});

  factory SearchResultDto.fromJson(Map<String, Object?> json) =>
      _$SearchResultDtoFromJson(json);

  final String query;

  /// One group per kind that exists today. A kind with no results has a count of zero.
  final List<SearchGroupDto> groups;

  Map<String, Object?> toJson() => _$SearchResultDtoToJson(this);
}
