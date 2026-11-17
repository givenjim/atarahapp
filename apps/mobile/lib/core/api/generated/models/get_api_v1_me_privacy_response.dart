// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_dto.dart';

part 'get_api_v1_me_privacy_response.g.dart';

@JsonSerializable()
class GetApiV1MePrivacyResponse {
  const GetApiV1MePrivacyResponse({required this.data, this.meta});

  factory GetApiV1MePrivacyResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MePrivacyResponseFromJson(json);

  final PrivacyDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MePrivacyResponseToJson(this);
}
