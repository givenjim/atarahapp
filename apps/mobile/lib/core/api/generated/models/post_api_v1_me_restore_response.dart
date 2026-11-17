// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'restored_dto.dart';

part 'post_api_v1_me_restore_response.g.dart';

@JsonSerializable()
class PostApiV1MeRestoreResponse {
  const PostApiV1MeRestoreResponse({required this.data, this.meta});

  factory PostApiV1MeRestoreResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeRestoreResponseFromJson(json);

  final RestoredDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeRestoreResponseToJson(this);
}
