// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'audience_preview_dto.g.dart';

@JsonSerializable()
class AudiencePreviewDto {
  const AudiencePreviewDto({
    required this.recipients,
  });
  
  factory AudiencePreviewDto.fromJson(Map<String, Object?> json) => _$AudiencePreviewDtoFromJson(json);
  
  /// How many members would receive it.
  final num recipients;

  Map<String, Object?> toJson() => _$AudiencePreviewDtoToJson(this);
}
