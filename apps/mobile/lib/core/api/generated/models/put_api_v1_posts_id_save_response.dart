// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'saved_state_dto.dart';

part 'put_api_v1_posts_id_save_response.g.dart';

@JsonSerializable()
class PutApiV1PostsIdSaveResponse {
  const PutApiV1PostsIdSaveResponse({required this.data, this.meta});

  factory PutApiV1PostsIdSaveResponse.fromJson(Map<String, Object?> json) =>
      _$PutApiV1PostsIdSaveResponseFromJson(json);

  final SavedStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1PostsIdSaveResponseToJson(this);
}
