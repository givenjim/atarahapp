// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_opportunity_providers_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminOpportunityProvidersIdResponse
_$PatchApiV1AdminOpportunityProvidersIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminOpportunityProvidersIdResponse(
  data: AdminProviderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminOpportunityProvidersIdResponseToJson(
  PatchApiV1AdminOpportunityProvidersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
