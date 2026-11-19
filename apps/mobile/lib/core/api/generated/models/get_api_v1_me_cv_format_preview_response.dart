// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_preview_dto.dart';

part 'get_api_v1_me_cv_format_preview_response.g.dart';

@JsonSerializable()
class GetApiV1MeCvFormatPreviewResponse {
  const GetApiV1MeCvFormatPreviewResponse({required this.data, this.meta});

  factory GetApiV1MeCvFormatPreviewResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1MeCvFormatPreviewResponseFromJson(json);

  final CvPreviewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1MeCvFormatPreviewResponseToJson(this);
}
