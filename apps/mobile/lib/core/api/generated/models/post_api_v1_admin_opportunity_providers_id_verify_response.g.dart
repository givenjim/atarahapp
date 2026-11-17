// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunity_providers_id_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunityProvidersIdVerifyResponse
_$PostApiV1AdminOpportunityProvidersIdVerifyResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunityProvidersIdVerifyResponse(
  data: AdminProviderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunityProvidersIdVerifyResponseToJson(
  PostApiV1AdminOpportunityProvidersIdVerifyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
