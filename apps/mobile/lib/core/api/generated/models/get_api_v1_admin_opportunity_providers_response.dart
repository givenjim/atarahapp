// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_provider_dto.dart';

part 'get_api_v1_admin_opportunity_providers_response.g.dart';

@JsonSerializable()
class GetApiV1AdminOpportunityProvidersResponse {
  const GetApiV1AdminOpportunityProvidersResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1AdminOpportunityProvidersResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminOpportunityProvidersResponseFromJson(json);

  final List<AdminProviderDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminOpportunityProvidersResponseToJson(this);
}
