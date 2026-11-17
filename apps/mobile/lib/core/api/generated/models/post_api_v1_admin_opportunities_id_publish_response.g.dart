// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdPublishResponse
_$PostApiV1AdminOpportunitiesIdPublishResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdPublishResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdPublishResponseToJson(
  PostApiV1AdminOpportunitiesIdPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
