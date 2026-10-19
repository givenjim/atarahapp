// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'experience_dto.dart';

part 'get_api_v1_me_experience_response.g.dart';

@JsonSerializable()
class GetApiV1MeExperienceResponse {
  const GetApiV1MeExperienceResponse({required this.data, this.meta});

  factory GetApiV1MeExperienceResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeExperienceResponseFromJson(json);

  final List<ExperienceDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeExperienceResponseToJson(this);
}
