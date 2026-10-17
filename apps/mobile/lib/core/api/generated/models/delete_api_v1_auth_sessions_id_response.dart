// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'revoked_dto.dart';

part 'delete_api_v1_auth_sessions_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1AuthSessionsIdResponse {
  const DeleteApiV1AuthSessionsIdResponse({required this.data, this.meta});

  factory DeleteApiV1AuthSessionsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$DeleteApiV1AuthSessionsIdResponseFromJson(json);

  final RevokedDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1AuthSessionsIdResponseToJson(this);
}
