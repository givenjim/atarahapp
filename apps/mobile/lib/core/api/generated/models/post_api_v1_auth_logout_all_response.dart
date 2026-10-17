// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sessions_revoked_dto.dart';

part 'post_api_v1_auth_logout_all_response.g.dart';

@JsonSerializable()
class PostApiV1AuthLogoutAllResponse {
  const PostApiV1AuthLogoutAllResponse({required this.data, this.meta});

  factory PostApiV1AuthLogoutAllResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AuthLogoutAllResponseFromJson(json);

  final SessionsRevokedDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AuthLogoutAllResponseToJson(this);
}
