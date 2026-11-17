// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_visibility.dart';

part 'update_group_dto.g.dart';

@JsonSerializable()
class UpdateGroupDto {
  const UpdateGroupDto({
    required this.name,
    required this.description,
    required this.disciplineId,
    required this.countyId,
    required this.coverMediaId,
    required this.isOfficial,
    required this.visibility,
  });

  factory UpdateGroupDto.fromJson(Map<String, Object?> json) =>
      _$UpdateGroupDtoFromJson(json);

  final String name;
  final String description;
  final String? disciplineId;
  final String? countyId;
  final String? coverMediaId;
  final bool isOfficial;
  final GroupVisibility visibility;

  Map<String, Object?> toJson() => _$UpdateGroupDtoToJson(this);
}
