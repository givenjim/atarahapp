// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'contact_change_started_dto.dart';

part 'post_api_v1_me_email_change_response.g.dart';

@JsonSerializable()
class PostApiV1MeEmailChangeResponse {
  const PostApiV1MeEmailChangeResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeEmailChangeResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeEmailChangeResponseFromJson(json);
  
  final ContactChangeStartedDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeEmailChangeResponseToJson(this);
}
