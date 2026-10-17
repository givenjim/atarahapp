// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session_view_dto.dart';

part 'get_api_v1_auth_sessions_response.g.dart';

@JsonSerializable()
class GetApiV1AuthSessionsResponse {
  const GetApiV1AuthSessionsResponse({required this.data, this.meta});

  factory GetApiV1AuthSessionsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AuthSessionsResponseFromJson(json);

  final List<SessionViewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AuthSessionsResponseToJson(this);
}
