// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'home_config_dto.dart';

part 'put_api_v1_admin_home_response.g.dart';

@JsonSerializable()
class PutApiV1AdminHomeResponse {
  const PutApiV1AdminHomeResponse({required this.data, this.meta});

  factory PutApiV1AdminHomeResponse.fromJson(Map<String, Object?> json) =>
      _$PutApiV1AdminHomeResponseFromJson(json);

  final HomeConfigDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1AdminHomeResponseToJson(this);
}
