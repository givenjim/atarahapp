// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'mentor_status_change_dto.g.dart';

@JsonSerializable()
class MentorStatusChangeDto {
  const MentorStatusChangeDto({
    required this.reason,
  });
  
  factory MentorStatusChangeDto.fromJson(Map<String, Object?> json) => _$MentorStatusChangeDtoFromJson(json);
  
  /// Why; recorded in the audit log and shown to the mentor.
  final String reason;

  Map<String, Object?> toJson() => _$MentorStatusChangeDtoToJson(this);
}
