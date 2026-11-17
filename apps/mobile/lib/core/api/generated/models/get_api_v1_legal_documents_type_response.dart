// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_full_dto.dart';

part 'get_api_v1_legal_documents_type_response.g.dart';

@JsonSerializable()
class GetApiV1LegalDocumentsTypeResponse {
  const GetApiV1LegalDocumentsTypeResponse({required this.data, this.meta});

  factory GetApiV1LegalDocumentsTypeResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LegalDocumentsTypeResponseFromJson(json);

  final LegalFullDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LegalDocumentsTypeResponseToJson(this);
}
