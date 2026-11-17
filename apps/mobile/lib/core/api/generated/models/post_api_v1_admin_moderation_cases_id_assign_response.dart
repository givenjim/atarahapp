// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_dto.dart';

part 'post_api_v1_admin_moderation_cases_id_assign_response.g.dart';

@JsonSerializable()
class PostApiV1AdminModerationCasesIdAssignResponse {
  const PostApiV1AdminModerationCasesIdAssignResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminModerationCasesIdAssignResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminModerationCasesIdAssignResponseFromJson(json);

  final AdminCaseDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminModerationCasesIdAssignResponseToJson(this);
}
