// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_opportunities_id_save_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1OpportunitiesIdSaveResponse
_$PutApiV1OpportunitiesIdSaveResponseFromJson(Map<String, dynamic> json) =>
    PutApiV1OpportunitiesIdSaveResponse(
      data: TrackingStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PutApiV1OpportunitiesIdSaveResponseToJson(
  PutApiV1OpportunitiesIdSaveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
