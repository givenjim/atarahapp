// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'feature_mentor_dto.g.dart';

@JsonSerializable()
class FeatureMentorDto {
  const FeatureMentorDto({
    required this.featured,
  });
  
  factory FeatureMentorDto.fromJson(Map<String, Object?> json) => _$FeatureMentorDtoFromJson(json);
  
  final bool featured;

  Map<String, Object?> toJson() => _$FeatureMentorDtoToJson(this);
}
