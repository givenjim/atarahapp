// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'register_result_dto.dart';

part 'post_api_v1_auth_register_response.g.dart';

@JsonSerializable()
class PostApiV1AuthRegisterResponse {
  const PostApiV1AuthRegisterResponse({required this.data, this.meta});

  factory PostApiV1AuthRegisterResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AuthRegisterResponseFromJson(json);

  final RegisterResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AuthRegisterResponseToJson(this);
}
