// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'home_config_dto.dart';

part 'get_api_v1_admin_home_response.g.dart';

@JsonSerializable()
class GetApiV1AdminHomeResponse {
  const GetApiV1AdminHomeResponse({required this.data, this.meta});

  factory GetApiV1AdminHomeResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminHomeResponseFromJson(json);

  final HomeConfigDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminHomeResponseToJson(this);
}
