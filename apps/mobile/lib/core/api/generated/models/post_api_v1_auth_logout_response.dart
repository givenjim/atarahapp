// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'logged_out_dto.dart';

part 'post_api_v1_auth_logout_response.g.dart';

@JsonSerializable()
class PostApiV1AuthLogoutResponse {
  const PostApiV1AuthLogoutResponse({required this.data, this.meta});

  factory PostApiV1AuthLogoutResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AuthLogoutResponseFromJson(json);

  final LoggedOutDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AuthLogoutResponseToJson(this);
}
