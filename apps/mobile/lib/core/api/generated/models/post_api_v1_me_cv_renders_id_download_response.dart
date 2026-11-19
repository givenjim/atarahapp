// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_download_dto.dart';

part 'post_api_v1_me_cv_renders_id_download_response.g.dart';

@JsonSerializable()
class PostApiV1MeCvRendersIdDownloadResponse {
  const PostApiV1MeCvRendersIdDownloadResponse({required this.data, this.meta});

  factory PostApiV1MeCvRendersIdDownloadResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1MeCvRendersIdDownloadResponseFromJson(json);

  final CvDownloadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MeCvRendersIdDownloadResponseToJson(this);
}
