// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_state_dto.dart';

part 'post_api_v1_connections_id_decline_response.g.dart';

@JsonSerializable()
class PostApiV1ConnectionsIdDeclineResponse {
  const PostApiV1ConnectionsIdDeclineResponse({required this.data, this.meta});

  factory PostApiV1ConnectionsIdDeclineResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1ConnectionsIdDeclineResponseFromJson(json);

  final ConnectionStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1ConnectionsIdDeclineResponseToJson(this);
}
