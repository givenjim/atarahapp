// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'own_profile_dto.dart';

part 'get_api_v1_me_profile_response.g.dart';

@JsonSerializable()
class GetApiV1MeProfileResponse {
  const GetApiV1MeProfileResponse({required this.data, this.meta});

  factory GetApiV1MeProfileResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeProfileResponseFromJson(json);

  final OwnProfileDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeProfileResponseToJson(this);
}
