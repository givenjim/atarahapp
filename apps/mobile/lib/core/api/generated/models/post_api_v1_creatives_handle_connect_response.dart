// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_state_dto.dart';

part 'post_api_v1_creatives_handle_connect_response.g.dart';

@JsonSerializable()
class PostApiV1CreativesHandleConnectResponse {
  const PostApiV1CreativesHandleConnectResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1CreativesHandleConnectResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1CreativesHandleConnectResponseFromJson(json);

  final ConnectionStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1CreativesHandleConnectResponseToJson(this);
}
