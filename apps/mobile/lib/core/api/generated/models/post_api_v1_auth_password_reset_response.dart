// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reset_dto.dart';

part 'post_api_v1_auth_password_reset_response.g.dart';

@JsonSerializable()
class PostApiV1AuthPasswordResetResponse {
  const PostApiV1AuthPasswordResetResponse({required this.data, this.meta});

  factory PostApiV1AuthPasswordResetResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AuthPasswordResetResponseFromJson(json);

  final ResetDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AuthPasswordResetResponseToJson(this);
}
