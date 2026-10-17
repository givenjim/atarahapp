// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'media_asset_dto.dart';

part 'post_api_v1_media_id_complete_response.g.dart';

@JsonSerializable()
class PostApiV1MediaIdCompleteResponse {
  const PostApiV1MediaIdCompleteResponse({required this.data, this.meta});

  factory PostApiV1MediaIdCompleteResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1MediaIdCompleteResponseFromJson(json);

  final MediaAssetDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MediaIdCompleteResponseToJson(this);
}
