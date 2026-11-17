// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_provider_opportunities_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1ProviderOpportunitiesIdResponse
_$PatchApiV1ProviderOpportunitiesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1ProviderOpportunitiesIdResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1ProviderOpportunitiesIdResponseToJson(
  PatchApiV1ProviderOpportunitiesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
