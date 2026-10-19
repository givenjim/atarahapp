// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_project_dto.g.dart';

@JsonSerializable()
class CreateProjectDto {
  const CreateProjectDto({this.title});

  factory CreateProjectDto.fromJson(Map<String, Object?> json) =>
      _$CreateProjectDtoFromJson(json);

  /// A draft may have no title yet.
  final String? title;

  Map<String, Object?> toJson() => _$CreateProjectDtoToJson(this);
}
