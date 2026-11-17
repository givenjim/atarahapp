// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_reject_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdRejectResponse
_$PostApiV1AdminOpportunitiesIdRejectResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdRejectResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdRejectResponseToJson(
  PostApiV1AdminOpportunitiesIdRejectResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
