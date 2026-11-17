// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_case_detail_dto.dart';

part 'post_api_v1_admin_moderation_cases_id_actions_response.g.dart';

@JsonSerializable()
class PostApiV1AdminModerationCasesIdActionsResponse {
  const PostApiV1AdminModerationCasesIdActionsResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminModerationCasesIdActionsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminModerationCasesIdActionsResponseFromJson(json);

  final AdminCaseDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminModerationCasesIdActionsResponseToJson(this);
}
