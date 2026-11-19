// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_render_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvRenderDto _$CvRenderDtoFromJson(Map<String, dynamic> json) => CvRenderDto(
  id: json['id'] as String,
  status: CvRenderDtoStatus.fromJson(json['status'] as String),
  requestedAt: DateTime.parse(json['requestedAt'] as String),
  readyAt: json['readyAt'] == null
      ? null
      : DateTime.parse(json['readyAt'] as String),
  error: json['error'] as String?,
);

Map<String, dynamic> _$CvRenderDtoToJson(CvRenderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'readyAt': instance.readyAt?.toIso8601String(),
      'error': instance.error,
    };
