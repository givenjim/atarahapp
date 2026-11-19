// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'activity_counts_dto.dart';
import 'resume_card_dto.dart';

part 'activity_dto.g.dart';

@JsonSerializable()
class ActivityDto {
  const ActivityDto({
    required this.resume,
    required this.counts,
  });
  
  factory ActivityDto.fromJson(Map<String, Object?> json) => _$ActivityDtoFromJson(json);
  
  final List<ResumeCardDto> resume;
  final ActivityCountsDto counts;

  Map<String, Object?> toJson() => _$ActivityDtoToJson(this);
}
