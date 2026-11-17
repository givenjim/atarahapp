// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_archive_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdArchiveResponse
_$PostApiV1AdminOpportunitiesIdArchiveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdArchiveResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdArchiveResponseToJson(
  PostApiV1AdminOpportunitiesIdArchiveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
