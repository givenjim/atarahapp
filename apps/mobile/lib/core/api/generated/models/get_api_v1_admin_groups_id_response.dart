// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_group_dto.dart';

part 'get_api_v1_admin_groups_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminGroupsIdResponse {
  const GetApiV1AdminGroupsIdResponse({required this.data, this.meta});

  factory GetApiV1AdminGroupsIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminGroupsIdResponseFromJson(json);

  final AdminGroupDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminGroupsIdResponseToJson(this);
}
