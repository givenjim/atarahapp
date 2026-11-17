// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_group_dto.dart';

part 'delete_api_v1_admin_groups_id_moderators_user_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1AdminGroupsIdModeratorsUserIdResponse {
  const DeleteApiV1AdminGroupsIdModeratorsUserIdResponse({
    required this.data,
    this.meta,
  });

  factory DeleteApiV1AdminGroupsIdModeratorsUserIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$DeleteApiV1AdminGroupsIdModeratorsUserIdResponseFromJson(json);

  final AdminGroupDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1AdminGroupsIdModeratorsUserIdResponseToJson(this);
}
