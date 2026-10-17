// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';

part 'get_api_v1_admin_users_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminUsersIdResponse {
  const GetApiV1AdminUsersIdResponse({required this.data, this.meta});

  factory GetApiV1AdminUsersIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminUsersIdResponseFromJson(json);

  final AdminUserDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminUsersIdResponseToJson(this);
}
