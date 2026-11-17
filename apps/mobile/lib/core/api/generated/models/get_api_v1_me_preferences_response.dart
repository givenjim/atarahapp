// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_preferences_dto.dart';

part 'get_api_v1_me_preferences_response.g.dart';

@JsonSerializable()
class GetApiV1MePreferencesResponse {
  const GetApiV1MePreferencesResponse({required this.data, this.meta});

  factory GetApiV1MePreferencesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MePreferencesResponseFromJson(json);

  final AccountPreferencesDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MePreferencesResponseToJson(this);
}
