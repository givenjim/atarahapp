// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'totp_setup_dto.dart';

part 'post_api_v1_admin_auth_totp_setup_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAuthTotpSetupResponse {
  const PostApiV1AdminAuthTotpSetupResponse({required this.data, this.meta});

  factory PostApiV1AdminAuthTotpSetupResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminAuthTotpSetupResponseFromJson(json);

  final TotpSetupDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAuthTotpSetupResponseToJson(this);
}
