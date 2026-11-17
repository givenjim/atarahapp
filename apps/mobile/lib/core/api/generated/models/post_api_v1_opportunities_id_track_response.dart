// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tracking_state_dto.dart';

part 'post_api_v1_opportunities_id_track_response.g.dart';

@JsonSerializable()
class PostApiV1OpportunitiesIdTrackResponse {
  const PostApiV1OpportunitiesIdTrackResponse({required this.data, this.meta});

  factory PostApiV1OpportunitiesIdTrackResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1OpportunitiesIdTrackResponseFromJson(json);

  final TrackingStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1OpportunitiesIdTrackResponseToJson(this);
}
