// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_render_dto.dart';

part 'post_api_v1_me_cv_format_generate_response.g.dart';

@JsonSerializable()
class PostApiV1MeCvFormatGenerateResponse {
  const PostApiV1MeCvFormatGenerateResponse({required this.data, this.meta});

  factory PostApiV1MeCvFormatGenerateResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1MeCvFormatGenerateResponseFromJson(json);

  final CvRenderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MeCvFormatGenerateResponseToJson(this);
}
