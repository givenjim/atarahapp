// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_faq_dto.dart';

part 'get_api_v1_admin_faq_response.g.dart';

@JsonSerializable()
class GetApiV1AdminFaqResponse {
  const GetApiV1AdminFaqResponse({required this.data, this.meta});

  factory GetApiV1AdminFaqResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminFaqResponseFromJson(json);

  final List<AdminFaqDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminFaqResponseToJson(this);
}
