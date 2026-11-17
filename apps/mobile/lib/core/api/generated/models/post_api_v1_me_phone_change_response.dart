// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'contact_change_started_dto.dart';

part 'post_api_v1_me_phone_change_response.g.dart';

@JsonSerializable()
class PostApiV1MePhoneChangeResponse {
  const PostApiV1MePhoneChangeResponse({required this.data, this.meta});

  factory PostApiV1MePhoneChangeResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MePhoneChangeResponseFromJson(json);

  final ContactChangeStartedDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MePhoneChangeResponseToJson(this);
}
