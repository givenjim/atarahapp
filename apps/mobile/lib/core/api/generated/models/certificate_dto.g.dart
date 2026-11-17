// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateDto _$CertificateDtoFromJson(Map<String, dynamic> json) =>
    CertificateDto(
      certificateNumber: json['certificateNumber'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      achievementId: json['achievementId'] as String?,
    );

Map<String, dynamic> _$CertificateDtoToJson(CertificateDto instance) =>
    <String, dynamic>{
      'certificateNumber': instance.certificateNumber,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'achievementId': instance.achievementId,
    };
