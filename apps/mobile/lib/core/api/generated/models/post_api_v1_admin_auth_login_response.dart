// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_login_step_dto.dart';

part 'post_api_v1_admin_auth_login_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAuthLoginResponse {
  const PostApiV1AdminAuthLoginResponse({required this.data, this.meta});

  factory PostApiV1AdminAuthLoginResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AdminAuthLoginResponseFromJson(json);

  final AdminLoginStepDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAuthLoginResponseToJson(this);
}
