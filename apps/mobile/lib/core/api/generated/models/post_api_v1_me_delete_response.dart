// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'deletion_state_dto.dart';

part 'post_api_v1_me_delete_response.g.dart';

@JsonSerializable()
class PostApiV1MeDeleteResponse {
  const PostApiV1MeDeleteResponse({required this.data, this.meta});

  factory PostApiV1MeDeleteResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeDeleteResponseFromJson(json);

  final DeletionStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeDeleteResponseToJson(this);
}
