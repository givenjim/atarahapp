// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'experience_dto.g.dart';

@JsonSerializable()
class ExperienceDto {
  const ExperienceDto({
    required this.id,
    required this.title,
    required this.organisation,
    required this.startDate,
    required this.current,
    this.location,
    this.endDate,
    this.description,
  });

  factory ExperienceDto.fromJson(Map<String, Object?> json) =>
      _$ExperienceDtoFromJson(json);

  final String id;
  final String title;
  final String organisation;
  final String? location;

  /// A calendar date, YYYY-MM-DD.
  final String startDate;

  /// A calendar date, YYYY-MM-DD.
  final String? endDate;
  final bool current;
  final String? description;

  Map<String, Object?> toJson() => _$ExperienceDtoToJson(this);
}
