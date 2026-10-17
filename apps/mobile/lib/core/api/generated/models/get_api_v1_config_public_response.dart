// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'public_config_dto.dart';

part 'get_api_v1_config_public_response.g.dart';

@JsonSerializable()
class GetApiV1ConfigPublicResponse {
  const GetApiV1ConfigPublicResponse({required this.data, this.meta});

  factory GetApiV1ConfigPublicResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1ConfigPublicResponseFromJson(json);

  final PublicConfigDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1ConfigPublicResponseToJson(this);
}
