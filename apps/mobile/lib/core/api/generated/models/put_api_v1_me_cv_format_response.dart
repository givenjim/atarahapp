// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_state_dto.dart';

part 'put_api_v1_me_cv_format_response.g.dart';

@JsonSerializable()
class PutApiV1MeCvFormatResponse {
  const PutApiV1MeCvFormatResponse({required this.data, this.meta});

  factory PutApiV1MeCvFormatResponse.fromJson(Map<String, Object?> json) =>
      _$PutApiV1MeCvFormatResponseFromJson(json);

  final CvStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1MeCvFormatResponseToJson(this);
}
