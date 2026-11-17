// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'certificate_dto.g.dart';

@JsonSerializable()
class CertificateDto {
  const CertificateDto({
    required this.certificateNumber,
    required this.issuedAt,
    this.achievementId,
  });

  factory CertificateDto.fromJson(Map<String, Object?> json) =>
      _$CertificateDtoFromJson(json);

  final String certificateNumber;
  final DateTime issuedAt;
  final String? achievementId;

  Map<String, Object?> toJson() => _$CertificateDtoToJson(this);
}
