// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'activity_dto.dart';

part 'get_api_v1_me_activity_response.g.dart';

@JsonSerializable()
class GetApiV1MeActivityResponse {
  const GetApiV1MeActivityResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeActivityResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeActivityResponseFromJson(json);
  
  final ActivityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeActivityResponseToJson(this);
}
