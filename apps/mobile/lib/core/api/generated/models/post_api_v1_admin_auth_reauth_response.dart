// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reauth_dto.dart';

part 'post_api_v1_admin_auth_reauth_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAuthReauthResponse {
  const PostApiV1AdminAuthReauthResponse({required this.data, this.meta});

  factory PostApiV1AdminAuthReauthResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminAuthReauthResponseFromJson(json);

  final ReauthDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAuthReauthResponseToJson(this);
}
