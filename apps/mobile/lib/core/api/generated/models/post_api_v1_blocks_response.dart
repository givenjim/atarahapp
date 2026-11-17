// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'blocked_member_dto.dart';

part 'post_api_v1_blocks_response.g.dart';

@JsonSerializable()
class PostApiV1BlocksResponse {
  const PostApiV1BlocksResponse({required this.data, this.meta});

  factory PostApiV1BlocksResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1BlocksResponseFromJson(json);

  final BlockedMemberDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1BlocksResponseToJson(this);
}
