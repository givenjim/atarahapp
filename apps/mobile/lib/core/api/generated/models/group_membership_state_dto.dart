// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_membership_state_dto.g.dart';

@JsonSerializable()
class GroupMembershipStateDto {
  const GroupMembershipStateDto({
    required this.groupId,
    required this.joined,
    required this.memberCount,
  });

  factory GroupMembershipStateDto.fromJson(Map<String, Object?> json) =>
      _$GroupMembershipStateDtoFromJson(json);

  final String groupId;
  final bool joined;
  final num memberCount;

  Map<String, Object?> toJson() => _$GroupMembershipStateDtoToJson(this);
}
