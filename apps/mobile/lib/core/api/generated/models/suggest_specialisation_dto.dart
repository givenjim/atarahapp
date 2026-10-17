// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'suggest_specialisation_dto.g.dart';

@JsonSerializable()
class SuggestSpecialisationDto {
  const SuggestSpecialisationDto({
    required this.disciplineId,
    required this.name,
  });

  factory SuggestSpecialisationDto.fromJson(Map<String, Object?> json) =>
      _$SuggestSpecialisationDtoFromJson(json);

  final String disciplineId;
  final String name;

  Map<String, Object?> toJson() => _$SuggestSpecialisationDtoToJson(this);
}
