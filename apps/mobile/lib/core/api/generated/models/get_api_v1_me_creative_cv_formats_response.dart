// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_format_info_dto.dart';

part 'get_api_v1_me_creative_cv_formats_response.g.dart';

@JsonSerializable()
class GetApiV1MeCreativeCvFormatsResponse {
  const GetApiV1MeCreativeCvFormatsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeCreativeCvFormatsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeCreativeCvFormatsResponseFromJson(json);
  
  final List<CvFormatInfoDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeCreativeCvFormatsResponseToJson(this);
}
