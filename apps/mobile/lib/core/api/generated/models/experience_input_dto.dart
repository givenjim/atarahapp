// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'experience_input_dto.g.dart';

@JsonSerializable()
class ExperienceInputDto {
  const ExperienceInputDto({
    required this.title,
    required this.organisation,
    required this.startDate,
    required this.current,
    this.location,
    this.endDate,
    this.description,
  });

  factory ExperienceInputDto.fromJson(Map<String, Object?> json) =>
      _$ExperienceInputDtoFromJson(json);

  final String title;

  /// Company, studio, school or "Freelance".
  final String organisation;
  final String? location;

  /// A calendar date, YYYY-MM-DD.
  final String startDate;

  /// A calendar date, YYYY-MM-DD. Leave out while you still work there.
  final String? endDate;

  /// You still work there. Cannot be combined with an end date.
  final bool current;
  final String? description;

  Map<String, Object?> toJson() => _$ExperienceInputDtoToJson(this);
}
