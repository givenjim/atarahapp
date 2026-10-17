// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_auth_session_dto.dart';

part 'post_api_v1_admin_auth_totp_verify_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAuthTotpVerifyResponse {
  const PostApiV1AdminAuthTotpVerifyResponse({required this.data, this.meta});

  factory PostApiV1AdminAuthTotpVerifyResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminAuthTotpVerifyResponseFromJson(json);

  final AdminAuthSessionDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAuthTotpVerifyResponseToJson(this);
}
