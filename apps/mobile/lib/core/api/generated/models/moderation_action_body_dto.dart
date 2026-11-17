// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'moderation_action.dart';

part 'moderation_action_body_dto.g.dart';

@JsonSerializable()
class ModerationActionBodyDto {
  const ModerationActionBodyDto({
    required this.action,
    this.reason,
    this.restrictDays,
  });

  factory ModerationActionBodyDto.fromJson(Map<String, Object?> json) =>
      _$ModerationActionBodyDtoFromJson(json);

  final ModerationAction action;

  /// Required for every action except NO_ACTION. Kept internal; never shown to reporters.
  final String? reason;

  /// RESTRICT_ACCOUNT only: lifts itself after this many days.
  final num? restrictDays;

  Map<String, Object?> toJson() => _$ModerationActionBodyDtoToJson(this);
}
