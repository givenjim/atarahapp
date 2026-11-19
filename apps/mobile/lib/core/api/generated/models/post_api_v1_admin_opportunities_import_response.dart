// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_commit_result_dto.dart';

part 'post_api_v1_admin_opportunities_import_response.g.dart';

@JsonSerializable()
class PostApiV1AdminOpportunitiesImportResponse {
  const PostApiV1AdminOpportunitiesImportResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminOpportunitiesImportResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminOpportunitiesImportResponseFromJson(json);
  
  final ImportCommitResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminOpportunitiesImportResponseToJson(this);
}
