// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reaction_state_dto.dart';

part 'delete_api_v1_posts_id_reactions_response.g.dart';

@JsonSerializable()
class DeleteApiV1PostsIdReactionsResponse {
  const DeleteApiV1PostsIdReactionsResponse({
    required this.data,
    this.meta,
  });
  
  factory DeleteApiV1PostsIdReactionsResponse.fromJson(Map<String, Object?> json) => _$DeleteApiV1PostsIdReactionsResponseFromJson(json);
  
  final ReactionStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1PostsIdReactionsResponseToJson(this);
}
