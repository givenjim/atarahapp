// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'specialisation_dto.dart';

part 'discipline_dto.g.dart';

@JsonSerializable()
class DisciplineDto {
  const DisciplineDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.specialisations,
  });

  factory DisciplineDto.fromJson(Map<String, Object?> json) =>
      _$DisciplineDtoFromJson(json);

  final String id;
  final String slug;
  final String name;

  /// Lucide icon name.
  final String icon;
  final List<SpecialisationDto> specialisations;

  Map<String, Object?> toJson() => _$DisciplineDtoToJson(this);
}
