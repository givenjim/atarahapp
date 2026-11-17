// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_opportunities_id_track_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1OpportunitiesIdTrackResponse
_$PostApiV1OpportunitiesIdTrackResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1OpportunitiesIdTrackResponse(
      data: TrackingStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1OpportunitiesIdTrackResponseToJson(
  PostApiV1OpportunitiesIdTrackResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
