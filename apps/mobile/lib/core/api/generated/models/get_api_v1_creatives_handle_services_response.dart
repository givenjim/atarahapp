// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'service_dto.dart';

part 'get_api_v1_creatives_handle_services_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleServicesResponse {
  const GetApiV1CreativesHandleServicesResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1CreativesHandleServicesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleServicesResponseFromJson(json);

  final List<ServiceDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleServicesResponseToJson(this);
}
