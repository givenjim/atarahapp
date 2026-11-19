// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_mentor_paused_dto.g.dart';

@JsonSerializable()
class SetMentorPausedDto {
  const SetMentorPausedDto({
    required this.paused,
  });
  
  factory SetMentorPausedDto.fromJson(Map<String, Object?> json) => _$SetMentorPausedDtoFromJson(json);
  
  /// true pauses the profile (hidden from the directory); false resumes it.
  final bool paused;

  Map<String, Object?> toJson() => _$SetMentorPausedDtoToJson(this);
}
