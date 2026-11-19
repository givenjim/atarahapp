// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_person_ref_dto.dart';
import 'group_staff_role.dart';

part 'admin_group_moderator_dto.g.dart';

@JsonSerializable()
class AdminGroupModeratorDto {
  const AdminGroupModeratorDto({
    required this.person,
    required this.role,
  });
  
  factory AdminGroupModeratorDto.fromJson(Map<String, Object?> json) => _$AdminGroupModeratorDtoFromJson(json);
  
  final AdminPersonRefDto person;
  final GroupStaffRole role;

  Map<String, Object?> toJson() => _$AdminGroupModeratorDtoToJson(this);
}
