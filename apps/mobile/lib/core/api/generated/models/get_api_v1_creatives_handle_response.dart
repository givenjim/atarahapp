// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'public_profile_dto.dart';

part 'get_api_v1_creatives_handle_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleResponse {
  const GetApiV1CreativesHandleResponse({required this.data, this.meta});

  factory GetApiV1CreativesHandleResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1CreativesHandleResponseFromJson(json);

  final PublicProfileDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleResponseToJson(this);
}
