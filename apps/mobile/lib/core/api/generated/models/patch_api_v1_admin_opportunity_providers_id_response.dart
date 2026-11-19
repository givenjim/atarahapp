// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_provider_dto.dart';

part 'patch_api_v1_admin_opportunity_providers_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminOpportunityProvidersIdResponse {
  const PatchApiV1AdminOpportunityProvidersIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminOpportunityProvidersIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminOpportunityProvidersIdResponseFromJson(json);
  
  final AdminProviderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminOpportunityProvidersIdResponseToJson(this);
}
