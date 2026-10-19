// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passport_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassportSummaryDto _$PassportSummaryDtoFromJson(Map<String, dynamic> json) =>
    PassportSummaryDto(
      passportNumber: json['passportNumber'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );

Map<String, dynamic> _$PassportSummaryDtoToJson(PassportSummaryDto instance) =>
    <String, dynamic>{
      'passportNumber': instance.passportNumber,
      'issuedAt': instance.issuedAt.toIso8601String(),
    };
