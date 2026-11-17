// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_group_dto.dart';

part 'delete_api_v1_admin_groups_id_pins_post_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1AdminGroupsIdPinsPostIdResponse {
  const DeleteApiV1AdminGroupsIdPinsPostIdResponse({
    required this.data,
    this.meta,
  });

  factory DeleteApiV1AdminGroupsIdPinsPostIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$DeleteApiV1AdminGroupsIdPinsPostIdResponseFromJson(json);

  final AdminGroupDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1AdminGroupsIdPinsPostIdResponseToJson(this);
}
