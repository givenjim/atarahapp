// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_dto.dart';

part 'get_api_v1_admin_moderation_cases_response.g.dart';

@JsonSerializable()
class GetApiV1AdminModerationCasesResponse {
  const GetApiV1AdminModerationCasesResponse({required this.data, this.meta});

  factory GetApiV1AdminModerationCasesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminModerationCasesResponseFromJson(json);

  final List<AdminCaseDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminModerationCasesResponseToJson(this);
}
