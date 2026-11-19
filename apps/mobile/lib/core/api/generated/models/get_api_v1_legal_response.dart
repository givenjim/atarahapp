// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_summary_dto.dart';

part 'get_api_v1_legal_response.g.dart';

@JsonSerializable()
class GetApiV1LegalResponse {
  const GetApiV1LegalResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1LegalResponse.fromJson(Map<String, Object?> json) => _$GetApiV1LegalResponseFromJson(json);
  
  final List<LegalSummaryDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LegalResponseToJson(this);
}
