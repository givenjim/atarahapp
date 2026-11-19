// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'get_api_v1_posts_id_response.g.dart';

@JsonSerializable()
class GetApiV1PostsIdResponse {
  const GetApiV1PostsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1PostsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1PostsIdResponseFromJson(json);
  
  final PostViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1PostsIdResponseToJson(this);
}
