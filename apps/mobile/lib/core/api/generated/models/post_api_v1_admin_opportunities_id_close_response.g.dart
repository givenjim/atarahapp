// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_close_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdCloseResponse
_$PostApiV1AdminOpportunitiesIdCloseResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdCloseResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdCloseResponseToJson(
  PostApiV1AdminOpportunitiesIdCloseResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
