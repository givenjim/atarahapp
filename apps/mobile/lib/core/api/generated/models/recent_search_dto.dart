// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'recent_search_dto.g.dart';

@JsonSerializable()
class RecentSearchDto {
  const RecentSearchDto({required this.id, required this.query});

  factory RecentSearchDto.fromJson(Map<String, Object?> json) =>
      _$RecentSearchDtoFromJson(json);

  final String id;
  final String query;

  Map<String, Object?> toJson() => _$RecentSearchDtoToJson(this);
}
