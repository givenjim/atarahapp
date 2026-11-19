// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_type.dart';
import 'group_visibility.dart';

part 'create_group_dto.g.dart';

@JsonSerializable()
class CreateGroupDto {
  const CreateGroupDto({
    required this.name,
    required this.type,
    this.isOfficial = true,
    this.visibility = GroupVisibility.open,
    this.slug,
    this.description,
    this.disciplineId,
    this.countyId,
    this.coverMediaId,
  });
  
  factory CreateGroupDto.fromJson(Map<String, Object?> json) => _$CreateGroupDtoFromJson(json);
  
  final String name;

  /// Lower-case words joined by hyphens. Defaults to the name.
  final String? slug;
  final GroupType type;
  final String? description;
  final String? disciplineId;
  final String? countyId;

  /// An uploaded image (media module).
  final String? coverMediaId;

  /// Run by Atarah.
  final bool isOfficial;
  final GroupVisibility visibility;

  Map<String, Object?> toJson() => _$CreateGroupDtoToJson(this);
}
