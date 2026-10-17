// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'verification_sent_dto_channel.dart';

part 'verification_sent_dto.g.dart';

@JsonSerializable()
class VerificationSentDto {
  const VerificationSentDto({
    required this.channel,
    required this.destination,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  factory VerificationSentDto.fromJson(Map<String, Object?> json) =>
      _$VerificationSentDtoFromJson(json);

  final VerificationSentDtoChannel channel;

  /// Masked destination, e.g. n***@gmail.com
  final String destination;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  Map<String, Object?> toJson() => _$VerificationSentDtoToJson(this);
}
