// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'decide_application_dto.g.dart';

@JsonSerializable()
class DecideApplicationDto {
  const DecideApplicationDto({
    this.reason,
  });
  
  factory DecideApplicationDto.fromJson(Map<String, Object?> json) => _$DecideApplicationDtoFromJson(json);
  
  /// Required when rejecting; shown to the applicant.
  final String? reason;

  Map<String, Object?> toJson() => _$DecideApplicationDtoToJson(this);
}
