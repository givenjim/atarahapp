// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_provider_dto.dart';

part 'get_api_v1_provider_organisations_response.g.dart';

@JsonSerializable()
class GetApiV1ProviderOrganisationsResponse {
  const GetApiV1ProviderOrganisationsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1ProviderOrganisationsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1ProviderOrganisationsResponseFromJson(json);
  
  final List<AdminProviderDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1ProviderOrganisationsResponseToJson(this);
}
