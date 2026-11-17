// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_staff_role.dart';

part 'group_moderator_body_dto.g.dart';

@JsonSerializable()
class GroupModeratorBodyDto {
  const GroupModeratorBodyDto({
    required this.userId,
    this.role = GroupStaffRole.moderator,
  });

  factory GroupModeratorBodyDto.fromJson(Map<String, Object?> json) =>
      _$GroupModeratorBodyDtoFromJson(json);

  final String userId;
  final GroupStaffRole role;

  Map<String, Object?> toJson() => _$GroupModeratorBodyDtoToJson(this);
}
