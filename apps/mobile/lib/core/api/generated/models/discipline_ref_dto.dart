// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'discipline_ref_dto.g.dart';

@JsonSerializable()
class DisciplineRefDto {
  const DisciplineRefDto({
    required this.id,
    required this.name,
  });
  
  factory DisciplineRefDto.fromJson(Map<String, Object?> json) => _$DisciplineRefDtoFromJson(json);
  
  final String id;
  final String name;

  Map<String, Object?> toJson() => _$DisciplineRefDtoToJson(this);
}
