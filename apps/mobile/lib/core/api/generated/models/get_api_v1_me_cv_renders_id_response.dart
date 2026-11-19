// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_render_dto.dart';

part 'get_api_v1_me_cv_renders_id_response.g.dart';

@JsonSerializable()
class GetApiV1MeCvRendersIdResponse {
  const GetApiV1MeCvRendersIdResponse({required this.data, this.meta});

  factory GetApiV1MeCvRendersIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeCvRendersIdResponseFromJson(json);

  final CvRenderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeCvRendersIdResponseToJson(this);
}
