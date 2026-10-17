// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'media_asset_dto.dart';

part 'get_api_v1_media_id_response.g.dart';

@JsonSerializable()
class GetApiV1MediaIdResponse {
  const GetApiV1MediaIdResponse({required this.data, this.meta});

  factory GetApiV1MediaIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MediaIdResponseFromJson(json);

  final MediaAssetDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MediaIdResponseToJson(this);
}
