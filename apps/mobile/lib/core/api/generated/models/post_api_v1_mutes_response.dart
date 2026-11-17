// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mute_state_dto.dart';

part 'post_api_v1_mutes_response.g.dart';

@JsonSerializable()
class PostApiV1MutesResponse {
  const PostApiV1MutesResponse({required this.data, this.meta});

  factory PostApiV1MutesResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MutesResponseFromJson(json);

  final MuteStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MutesResponseToJson(this);
}
