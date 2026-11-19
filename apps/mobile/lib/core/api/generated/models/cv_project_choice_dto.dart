// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_project_choice_dto_visibility.dart';

part 'cv_project_choice_dto.g.dart';

@JsonSerializable()
class CvProjectChoiceDto {
  const CvProjectChoiceDto({
    required this.id,
    required this.title,
    required this.visibility,
    this.role,
    this.year,
  });
  
  factory CvProjectChoiceDto.fromJson(Map<String, Object?> json) => _$CvProjectChoiceDtoFromJson(json);
  
  final String id;
  final String title;
  final String? role;
  final num? year;
  final CvProjectChoiceDtoVisibility visibility;

  Map<String, Object?> toJson() => _$CvProjectChoiceDtoToJson(this);
}
