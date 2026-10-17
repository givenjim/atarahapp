// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';

part 'post_api_v1_admin_users_id_suspend_response.g.dart';

@JsonSerializable()
class PostApiV1AdminUsersIdSuspendResponse {
  const PostApiV1AdminUsersIdSuspendResponse({required this.data, this.meta});

  factory PostApiV1AdminUsersIdSuspendResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminUsersIdSuspendResponseFromJson(json);

  final AdminUserDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminUsersIdSuspendResponseToJson(this);
}
