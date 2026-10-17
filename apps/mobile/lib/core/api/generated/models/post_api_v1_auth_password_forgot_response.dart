// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sent_dto.dart';

part 'post_api_v1_auth_password_forgot_response.g.dart';

@JsonSerializable()
class PostApiV1AuthPasswordForgotResponse {
  const PostApiV1AuthPasswordForgotResponse({required this.data, this.meta});

  factory PostApiV1AuthPasswordForgotResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AuthPasswordForgotResponseFromJson(json);

  final SentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AuthPasswordForgotResponseToJson(this);
}
