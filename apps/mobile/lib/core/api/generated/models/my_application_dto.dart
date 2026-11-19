// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_application_dto.dart';

part 'my_application_dto.g.dart';

@JsonSerializable()
class MyApplicationDto {
  const MyApplicationDto({
    required this.canApply,
    this.latest,
    this.cannotApplyReason,
  });
  
  factory MyApplicationDto.fromJson(Map<String, Object?> json) => _$MyApplicationDtoFromJson(json);
  
  final MentorApplicationDto? latest;

  /// The member may submit a new application now.
  final bool canApply;
  final String? cannotApplyReason;

  Map<String, Object?> toJson() => _$MyApplicationDtoToJson(this);
}
