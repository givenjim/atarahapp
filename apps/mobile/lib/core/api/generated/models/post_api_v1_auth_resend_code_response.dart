// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resend_result_dto.dart';

part 'post_api_v1_auth_resend_code_response.g.dart';

@JsonSerializable()
class PostApiV1AuthResendCodeResponse {
  const PostApiV1AuthResendCodeResponse({required this.data, this.meta});

  factory PostApiV1AuthResendCodeResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AuthResendCodeResponseFromJson(json);

  final ResendResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AuthResendCodeResponseToJson(this);
}
