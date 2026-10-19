// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_state_dto.dart';

part 'delete_api_v1_connections_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1ConnectionsIdResponse {
  const DeleteApiV1ConnectionsIdResponse({required this.data, this.meta});

  factory DeleteApiV1ConnectionsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$DeleteApiV1ConnectionsIdResponseFromJson(json);

  final ConnectionStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1ConnectionsIdResponseToJson(this);
}
