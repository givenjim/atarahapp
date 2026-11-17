// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assign_case_body_dto.g.dart';

@JsonSerializable()
class AssignCaseBodyDto {
  const AssignCaseBodyDto({this.assigneeId});

  factory AssignCaseBodyDto.fromJson(Map<String, Object?> json) =>
      _$AssignCaseBodyDtoFromJson(json);

  /// A staff member who can resolve reports; null or omitted unassigns.
  final String? assigneeId;

  Map<String, Object?> toJson() => _$AssignCaseBodyDtoToJson(this);
}
