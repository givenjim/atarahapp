// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'passport_preview_dto.g.dart';

@JsonSerializable()
class PassportPreviewDto {
  const PassportPreviewDto({
    required this.passportNumber,
    required this.issuedAt,
  });

  factory PassportPreviewDto.fromJson(Map<String, Object?> json) =>
      _$PassportPreviewDtoFromJson(json);

  final String passportNumber;
  final DateTime issuedAt;

  Map<String, Object?> toJson() => _$PassportPreviewDtoToJson(this);
}
