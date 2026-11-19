// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_opportunity_dto.dart';

part 'get_api_v1_provider_opportunities_id_response.g.dart';

@JsonSerializable()
class GetApiV1ProviderOpportunitiesIdResponse {
  const GetApiV1ProviderOpportunitiesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1ProviderOpportunitiesIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1ProviderOpportunitiesIdResponseFromJson(json);
  
  final AdminOpportunityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1ProviderOpportunitiesIdResponseToJson(this);
}
