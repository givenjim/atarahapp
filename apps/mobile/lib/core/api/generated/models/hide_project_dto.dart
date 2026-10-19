// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'hide_project_dto.g.dart';

@JsonSerializable()
class HideProjectDto {
  const HideProjectDto({required this.reason});

  factory HideProjectDto.fromJson(Map<String, Object?> json) =>
      _$HideProjectDtoFromJson(json);

  /// Shown to the owner.
  final String reason;

  Map<String, Object?> toJson() => _$HideProjectDtoToJson(this);
}
