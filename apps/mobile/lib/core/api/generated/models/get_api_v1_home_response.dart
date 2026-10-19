// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'home_dto.dart';

part 'get_api_v1_home_response.g.dart';

@JsonSerializable()
class GetApiV1HomeResponse {
  const GetApiV1HomeResponse({required this.data, this.meta});

  factory GetApiV1HomeResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1HomeResponseFromJson(json);

  final HomeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1HomeResponseToJson(this);
}
