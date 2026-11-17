// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_group_dto.dart';

part 'post_api_v1_admin_groups_id_pins_response.g.dart';

@JsonSerializable()
class PostApiV1AdminGroupsIdPinsResponse {
  const PostApiV1AdminGroupsIdPinsResponse({required this.data, this.meta});

  factory PostApiV1AdminGroupsIdPinsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminGroupsIdPinsResponseFromJson(json);

  final AdminGroupDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminGroupsIdPinsResponseToJson(this);
}
