// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_dto.dart';

part 'patch_api_v1_me_services_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeServicesIdResponse {
  const PatchApiV1MeServicesIdResponse({required this.data, this.meta});

  factory PatchApiV1MeServicesIdResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1MeServicesIdResponseFromJson(json);

  final ServiceDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeServicesIdResponseToJson(this);
}
