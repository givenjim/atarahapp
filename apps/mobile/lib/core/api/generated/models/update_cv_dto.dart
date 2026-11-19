// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_cv_dto_restricted.dart';
import 'update_cv_dto_sections.dart';

part 'update_cv_dto.g.dart';

@JsonSerializable()
class UpdateCvDto {
  const UpdateCvDto({
    this.sections,
    this.projectIds,
    this.restricted,
  });
  
  factory UpdateCvDto.fromJson(Map<String, Object?> json) => _$UpdateCvDtoFromJson(json);
  
  final List<UpdateCvDtoSections>? sections;

  /// The member’s own published projects to list.
  final List<String>? projectIds;

  /// Sections that are not public (members only or private) that the member explicitly allows into this document.
  final List<UpdateCvDtoRestricted>? restricted;

  Map<String, Object?> toJson() => _$UpdateCvDtoToJson(this);
}
