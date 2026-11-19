// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_share_created_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvShareCreatedDto _$CvShareCreatedDtoFromJson(Map<String, dynamic> json) =>
    CvShareCreatedDto(
      id: json['id'] as String,
      hint: json['hint'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: CvShareCreatedDtoStatus.fromJson(json['status'] as String),
      url: json['url'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
    );

Map<String, dynamic> _$CvShareCreatedDtoToJson(CvShareCreatedDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hint': instance.hint,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'status': instance.status,
      'url': instance.url,
    };
