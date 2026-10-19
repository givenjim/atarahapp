// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'passport_summary_dto.g.dart';

@JsonSerializable()
class PassportSummaryDto {
  const PassportSummaryDto({
    required this.passportNumber,
    required this.issuedAt,
  });

  factory PassportSummaryDto.fromJson(Map<String, Object?> json) =>
      _$PassportSummaryDtoFromJson(json);

  final String passportNumber;
  final DateTime issuedAt;

  Map<String, Object?> toJson() => _$PassportSummaryDtoToJson(this);
}
