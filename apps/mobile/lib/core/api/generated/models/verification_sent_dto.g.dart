// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_sent_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationSentDto _$VerificationSentDtoFromJson(Map<String, dynamic> json) =>
    VerificationSentDto(
      channel: VerificationSentDtoChannel.fromJson(json['channel'] as String),
      destination: json['destination'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      resendAvailableAt: DateTime.parse(json['resendAvailableAt'] as String),
    );

Map<String, dynamic> _$VerificationSentDtoToJson(
  VerificationSentDto instance,
) => <String, dynamic>{
  'channel': instance.channel,
  'destination': instance.destination,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'resendAvailableAt': instance.resendAvailableAt.toIso8601String(),
};
