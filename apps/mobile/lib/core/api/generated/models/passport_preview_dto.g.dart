// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passport_preview_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassportPreviewDto _$PassportPreviewDtoFromJson(Map<String, dynamic> json) =>
    PassportPreviewDto(
      passportNumber: json['passportNumber'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );

Map<String, dynamic> _$PassportPreviewDtoToJson(PassportPreviewDto instance) =>
    <String, dynamic>{
      'passportNumber': instance.passportNumber,
      'issuedAt': instance.issuedAt.toIso8601String(),
    };
