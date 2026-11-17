// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'faq_dto.dart';

part 'get_api_v1_help_faq_response.g.dart';

@JsonSerializable()
class GetApiV1HelpFaqResponse {
  const GetApiV1HelpFaqResponse({required this.data, this.meta});

  factory GetApiV1HelpFaqResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1HelpFaqResponseFromJson(json);

  final List<FaqDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1HelpFaqResponseToJson(this);
}
