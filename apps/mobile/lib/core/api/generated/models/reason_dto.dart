// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reason_dto.g.dart';

@JsonSerializable()
class ReasonDto {
  const ReasonDto({
    required this.reason,
  });
  
  factory ReasonDto.fromJson(Map<String, Object?> json) => _$ReasonDtoFromJson(json);
  
  /// Recorded in the audit log; the member sees it for rejections.
  final String reason;

  Map<String, Object?> toJson() => _$ReasonDtoToJson(this);
}
