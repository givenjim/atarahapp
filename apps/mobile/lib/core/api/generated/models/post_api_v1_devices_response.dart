// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_dto.dart';

part 'post_api_v1_devices_response.g.dart';

@JsonSerializable()
class PostApiV1DevicesResponse {
  const PostApiV1DevicesResponse({required this.data, this.meta});

  factory PostApiV1DevicesResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1DevicesResponseFromJson(json);

  final DeviceDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1DevicesResponseToJson(this);
}
