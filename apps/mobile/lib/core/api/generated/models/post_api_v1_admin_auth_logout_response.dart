// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'logged_out_dto.dart';

part 'post_api_v1_admin_auth_logout_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAuthLogoutResponse {
  const PostApiV1AdminAuthLogoutResponse({required this.data, this.meta});

  factory PostApiV1AdminAuthLogoutResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminAuthLogoutResponseFromJson(json);

  final LoggedOutDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAuthLogoutResponseToJson(this);
}
