// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_detail_dto.dart';

part 'get_api_v1_admin_moderation_cases_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminModerationCasesIdResponse {
  const GetApiV1AdminModerationCasesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminModerationCasesIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminModerationCasesIdResponseFromJson(json);
  
  final AdminCaseDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminModerationCasesIdResponseToJson(this);
}
