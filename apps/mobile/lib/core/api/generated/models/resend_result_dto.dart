// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'resend_result_dto.g.dart';

@JsonSerializable()
class ResendResultDto {
  const ResendResultDto({required this.resendAvailableAt});

  factory ResendResultDto.fromJson(Map<String, Object?> json) =>
      _$ResendResultDtoFromJson(json);

  final DateTime? resendAvailableAt;

  Map<String, Object?> toJson() => _$ResendResultDtoToJson(this);
}
