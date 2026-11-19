// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_render_dto.dart';

part 'post_api_v1_me_creative_cv_format_generate_response.g.dart';

@JsonSerializable()
class PostApiV1MeCreativeCvFormatGenerateResponse {
  const PostApiV1MeCreativeCvFormatGenerateResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeCreativeCvFormatGenerateResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeCreativeCvFormatGenerateResponseFromJson(json);
  
  final CvRenderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeCreativeCvFormatGenerateResponseToJson(this);
}
