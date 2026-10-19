// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'passport_dto.dart';

part 'get_api_v1_me_passport_response.g.dart';

@JsonSerializable()
class GetApiV1MePassportResponse {
  const GetApiV1MePassportResponse({required this.data, this.meta});

  factory GetApiV1MePassportResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MePassportResponseFromJson(json);

  final PassportDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MePassportResponseToJson(this);
}
