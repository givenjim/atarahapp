// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_opportunity_providers_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminOpportunityProvidersIdResponse
_$GetApiV1AdminOpportunityProvidersIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminOpportunityProvidersIdResponse(
  data: AdminProviderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminOpportunityProvidersIdResponseToJson(
  GetApiV1AdminOpportunityProvidersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
