// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_faq_dto.dart';

part 'patch_api_v1_admin_faq_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminFaqIdResponse {
  const PatchApiV1AdminFaqIdResponse({required this.data, this.meta});

  factory PatchApiV1AdminFaqIdResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1AdminFaqIdResponseFromJson(json);

  final AdminFaqDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminFaqIdResponseToJson(this);
}
