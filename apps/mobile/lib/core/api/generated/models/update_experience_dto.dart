// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_experience_dto.g.dart';

@JsonSerializable()
class UpdateExperienceDto {
  const UpdateExperienceDto({
    this.title,
    this.organisation,
    this.location,
    this.startDate,
    this.endDate,
    this.current,
    this.description,
  });

  factory UpdateExperienceDto.fromJson(Map<String, Object?> json) =>
      _$UpdateExperienceDtoFromJson(json);

  final String? title;
  final String? organisation;

  /// Empty clears it.
  final String? location;
  final String? startDate;

  /// Empty clears it.
  final String? endDate;
  final bool? current;

  /// Empty clears it.
  final String? description;

  Map<String, Object?> toJson() => _$UpdateExperienceDtoToJson(this);
}
