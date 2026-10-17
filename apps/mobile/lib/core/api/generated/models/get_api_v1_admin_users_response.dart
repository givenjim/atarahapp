// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';

part 'get_api_v1_admin_users_response.g.dart';

@JsonSerializable()
class GetApiV1AdminUsersResponse {
  const GetApiV1AdminUsersResponse({required this.data, this.meta});

  factory GetApiV1AdminUsersResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminUsersResponseFromJson(json);

  final List<AdminUserDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminUsersResponseToJson(this);
}
