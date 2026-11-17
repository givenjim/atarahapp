// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdVerifyResponse
_$PostApiV1AdminOpportunitiesIdVerifyResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdVerifyResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdVerifyResponseToJson(
  PostApiV1AdminOpportunitiesIdVerifyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
