// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_dto.dart';

part 'post_api_v1_me_phone_verify_response.g.dart';

@JsonSerializable()
class PostApiV1MePhoneVerifyResponse {
  const PostApiV1MePhoneVerifyResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MePhoneVerifyResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MePhoneVerifyResponseFromJson(json);
  
  final AccountDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MePhoneVerifyResponseToJson(this);
}
