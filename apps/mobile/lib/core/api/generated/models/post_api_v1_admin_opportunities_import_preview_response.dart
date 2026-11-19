// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_report_dto.dart';

part 'post_api_v1_admin_opportunities_import_preview_response.g.dart';

@JsonSerializable()
class PostApiV1AdminOpportunitiesImportPreviewResponse {
  const PostApiV1AdminOpportunitiesImportPreviewResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminOpportunitiesImportPreviewResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminOpportunitiesImportPreviewResponseFromJson(json);
  
  final ImportReportDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminOpportunitiesImportPreviewResponseToJson(this);
}
