// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'specialisation_dto.g.dart';

@JsonSerializable()
class SpecialisationDto {
  const SpecialisationDto({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory SpecialisationDto.fromJson(Map<String, Object?> json) =>
      _$SpecialisationDtoFromJson(json);

  final String id;
  final String slug;
  final String name;

  Map<String, Object?> toJson() => _$SpecialisationDtoToJson(this);
}
