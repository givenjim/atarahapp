// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_legal_dto.dart';

part 'post_api_v1_admin_legal_documents_response.g.dart';

@JsonSerializable()
class PostApiV1AdminLegalDocumentsResponse {
  const PostApiV1AdminLegalDocumentsResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminLegalDocumentsResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminLegalDocumentsResponseFromJson(json);
  
  final AdminLegalDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminLegalDocumentsResponseToJson(this);
}
