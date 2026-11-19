// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_membership_state_dto.dart';

part 'post_api_v1_groups_ref_leave_response.g.dart';

@JsonSerializable()
class PostApiV1GroupsRefLeaveResponse {
  const PostApiV1GroupsRefLeaveResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1GroupsRefLeaveResponse.fromJson(Map<String, Object?> json) => _$PostApiV1GroupsRefLeaveResponseFromJson(json);
  
  final GroupMembershipStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1GroupsRefLeaveResponseToJson(this);
}
