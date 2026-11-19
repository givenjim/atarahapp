// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'saved_counts_dto.g.dart';

@JsonSerializable()
class SavedCountsDto {
  const SavedCountsDto({
    required this.total,
    required this.byType,
  });
  
  factory SavedCountsDto.fromJson(Map<String, Object?> json) => _$SavedCountsDtoFromJson(json);
  
  final num total;

  /// Per kind.
  final Map<String, num> byType;

  Map<String, Object?> toJson() => _$SavedCountsDtoToJson(this);
}
