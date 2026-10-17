// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'auth_session_dto.dart';

part 'post_api_v1_auth_login_response.g.dart';

@JsonSerializable()
class PostApiV1AuthLoginResponse {
  const PostApiV1AuthLoginResponse({required this.data, this.meta});

  factory PostApiV1AuthLoginResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AuthLoginResponseFromJson(json);

  final AuthSessionDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AuthLoginResponseToJson(this);
}
