// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tracking_state_dto.dart';

part 'put_api_v1_opportunities_id_save_response.g.dart';

@JsonSerializable()
class PutApiV1OpportunitiesIdSaveResponse {
  const PutApiV1OpportunitiesIdSaveResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1OpportunitiesIdSaveResponse.fromJson(Map<String, Object?> json) => _$PutApiV1OpportunitiesIdSaveResponseFromJson(json);
  
  final TrackingStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1OpportunitiesIdSaveResponseToJson(this);
}
