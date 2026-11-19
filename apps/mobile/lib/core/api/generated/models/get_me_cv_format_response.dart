// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_state_dto.dart';

part 'get_me_cv_format_response.g.dart';

@JsonSerializable()
class GetMeCvFormatResponse {
  const GetMeCvFormatResponse({required this.data, this.meta});

  factory GetMeCvFormatResponse.fromJson(Map<String, Object?> json) =>
      _$GetMeCvFormatResponseFromJson(json);

  final CvStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetMeCvFormatResponseToJson(this);
}
