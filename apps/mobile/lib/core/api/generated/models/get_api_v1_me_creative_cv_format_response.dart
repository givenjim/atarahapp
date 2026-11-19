// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_state_dto.dart';

part 'get_api_v1_me_creative_cv_format_response.g.dart';

@JsonSerializable()
class GetApiV1MeCreativeCvFormatResponse {
  const GetApiV1MeCreativeCvFormatResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeCreativeCvFormatResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeCreativeCvFormatResponseFromJson(json);
  
  final CvStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeCreativeCvFormatResponseToJson(this);
}
