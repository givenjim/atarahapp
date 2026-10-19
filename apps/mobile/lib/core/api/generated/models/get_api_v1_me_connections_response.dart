// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_list_item_dto.dart';

part 'get_api_v1_me_connections_response.g.dart';

@JsonSerializable()
class GetApiV1MeConnectionsResponse {
  const GetApiV1MeConnectionsResponse({required this.data, this.meta});

  factory GetApiV1MeConnectionsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeConnectionsResponseFromJson(json);

  final List<ConnectionListItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeConnectionsResponseToJson(this);
}
