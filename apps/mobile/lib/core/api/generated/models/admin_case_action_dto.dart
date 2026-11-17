// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_person_ref_dto.dart';
import 'moderation_action.dart';

part 'admin_case_action_dto.g.dart';

@JsonSerializable()
class AdminCaseActionDto {
  const AdminCaseActionDto({
    required this.id,
    required this.action,
    required this.reason,
    required this.actor,
    required this.createdAt,
  });

  factory AdminCaseActionDto.fromJson(Map<String, Object?> json) =>
      _$AdminCaseActionDtoFromJson(json);

  final String id;
  final ModerationAction action;
  final String? reason;
  final AdminPersonRefDto? actor;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminCaseActionDtoToJson(this);
}
