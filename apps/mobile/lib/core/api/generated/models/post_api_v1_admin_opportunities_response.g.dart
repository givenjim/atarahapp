// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesResponse
_$PostApiV1AdminOpportunitiesResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminOpportunitiesResponse(
      data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminOpportunitiesResponseToJson(
  PostApiV1AdminOpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
