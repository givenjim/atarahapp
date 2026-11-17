// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_result_dto.dart';

part 'get_api_v1_help_response.g.dart';

@JsonSerializable()
class GetApiV1HelpResponse {
  const GetApiV1HelpResponse({required this.data, this.meta});

  factory GetApiV1HelpResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1HelpResponseFromJson(json);

  final HelpResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1HelpResponseToJson(this);
}
