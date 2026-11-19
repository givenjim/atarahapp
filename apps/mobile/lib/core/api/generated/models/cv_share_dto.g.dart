// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_share_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvShareDto _$CvShareDtoFromJson(Map<String, dynamic> json) => CvShareDto(
  id: json['id'] as String,
  hint: json['hint'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: CvShareDtoStatus.fromJson(json['status'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  revokedAt: json['revokedAt'] == null
      ? null
      : DateTime.parse(json['revokedAt'] as String),
);

Map<String, dynamic> _$CvShareDtoToJson(CvShareDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hint': instance.hint,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'status': instance.status,
    };
