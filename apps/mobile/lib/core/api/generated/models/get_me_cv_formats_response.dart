// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_format_info_dto.dart';

part 'get_me_cv_formats_response.g.dart';

@JsonSerializable()
class GetMeCvFormatsResponse {
  const GetMeCvFormatsResponse({required this.data, this.meta});

  factory GetMeCvFormatsResponse.fromJson(Map<String, Object?> json) =>
      _$GetMeCvFormatsResponseFromJson(json);

  final List<CvFormatInfoDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetMeCvFormatsResponseToJson(this);
}
