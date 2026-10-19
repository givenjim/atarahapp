// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'experience_dto.dart';

part 'get_api_v1_creatives_handle_experience_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleExperienceResponse {
  const GetApiV1CreativesHandleExperienceResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1CreativesHandleExperienceResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleExperienceResponseFromJson(json);

  final List<ExperienceDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleExperienceResponseToJson(this);
}
