// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_dto.dart';

part 'get_api_v1_legal_type_response.g.dart';

@JsonSerializable()
class GetApiV1LegalTypeResponse {
  const GetApiV1LegalTypeResponse({required this.data, this.meta});

  factory GetApiV1LegalTypeResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1LegalTypeResponseFromJson(json);

  final LegalDocumentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LegalTypeResponseToJson(this);
}
