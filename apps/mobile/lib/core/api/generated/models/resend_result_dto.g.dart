// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResendResultDto _$ResendResultDtoFromJson(Map<String, dynamic> json) =>
    ResendResultDto(
      resendAvailableAt: json['resendAvailableAt'] == null
          ? null
          : DateTime.parse(json['resendAvailableAt'] as String),
    );

Map<String, dynamic> _$ResendResultDtoToJson(ResendResultDto instance) =>
    <String, dynamic>{
      'resendAvailableAt': instance.resendAvailableAt?.toIso8601String(),
    };
