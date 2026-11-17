// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_legal_dto.dart';

part 'patch_api_v1_admin_legal_documents_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminLegalDocumentsIdResponse {
  const PatchApiV1AdminLegalDocumentsIdResponse({
    required this.data,
    this.meta,
  });

  factory PatchApiV1AdminLegalDocumentsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1AdminLegalDocumentsIdResponseFromJson(json);

  final AdminLegalDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1AdminLegalDocumentsIdResponseToJson(this);
}
