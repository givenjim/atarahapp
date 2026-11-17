// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_faq_dto.dart';

part 'post_api_v1_admin_faq_response.g.dart';

@JsonSerializable()
class PostApiV1AdminFaqResponse {
  const PostApiV1AdminFaqResponse({required this.data, this.meta});

  factory PostApiV1AdminFaqResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1AdminFaqResponseFromJson(json);

  final AdminFaqDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminFaqResponseToJson(this);
}
