// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'saved_state_dto.dart';

part 'delete_api_v1_posts_id_save_response.g.dart';

@JsonSerializable()
class DeleteApiV1PostsIdSaveResponse {
  const DeleteApiV1PostsIdSaveResponse({required this.data, this.meta});

  factory DeleteApiV1PostsIdSaveResponse.fromJson(Map<String, Object?> json) =>
      _$DeleteApiV1PostsIdSaveResponseFromJson(json);

  final SavedStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1PostsIdSaveResponseToJson(this);
}
