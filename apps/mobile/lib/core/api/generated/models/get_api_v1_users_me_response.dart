// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me_dto.dart';

part 'get_api_v1_users_me_response.g.dart';

@JsonSerializable()
class GetApiV1UsersMeResponse {
  const GetApiV1UsersMeResponse({required this.data, this.meta});

  factory GetApiV1UsersMeResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1UsersMeResponseFromJson(json);

  final MeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1UsersMeResponseToJson(this);
}
