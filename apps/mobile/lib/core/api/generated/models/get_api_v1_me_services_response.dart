// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_dto.dart';

part 'get_api_v1_me_services_response.g.dart';

@JsonSerializable()
class GetApiV1MeServicesResponse {
  const GetApiV1MeServicesResponse({required this.data, this.meta});

  factory GetApiV1MeServicesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeServicesResponseFromJson(json);

  final List<ServiceDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeServicesResponseToJson(this);
}
