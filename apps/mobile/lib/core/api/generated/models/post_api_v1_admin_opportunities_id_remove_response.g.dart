// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_remove_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdRemoveResponse
_$PostApiV1AdminOpportunitiesIdRemoveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdRemoveResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdRemoveResponseToJson(
  PostApiV1AdminOpportunitiesIdRemoveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
