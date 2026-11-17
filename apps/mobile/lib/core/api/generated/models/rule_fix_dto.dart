// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'rule_fix_dto.g.dart';

@JsonSerializable()
class RuleFixDto {
  const RuleFixDto({required this.label, required this.path});

  factory RuleFixDto.fromJson(Map<String, Object?> json) =>
      _$RuleFixDtoFromJson(json);

  final String label;

  /// An in-app path.
  final String path;

  Map<String, Object?> toJson() => _$RuleFixDtoToJson(this);
}
