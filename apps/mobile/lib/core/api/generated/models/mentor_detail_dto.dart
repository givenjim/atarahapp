// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'booking_gate_dto.dart';
import 'credential_out_dto.dart';
import 'discipline_ref_dto.dart';
import 'session_type_dto.dart';

part 'mentor_detail_dto.g.dart';

@JsonSerializable()
class MentorDetailDto {
  const MentorDetailDto({
    required this.id,
    required this.displayName,
    required this.headline,
    required this.expertiseTags,
    required this.verified,
    required this.featured,
    required this.ratingAverage,
    required this.ratingCount,
    required this.sessionsCount,
    required this.currency,
    required this.timeZone,
    required this.videoCall,
    required this.bio,
    required this.yearsExperience,
    required this.disciplines,
    required this.credentials,
    required this.sessionTypes,
    required this.booking,
    this.handle,
    this.avatarUrl,
    this.fromPriceMinor,
    this.nextAvailableAt,
  });
  
  factory MentorDetailDto.fromJson(Map<String, Object?> json) => _$MentorDetailDtoFromJson(json);
  
  /// The mentor profile id.
  final String id;
  final String? handle;
  final String displayName;
  final String? avatarUrl;
  final String headline;
  final List<String> expertiseTags;

  /// Identity verified by Atarah (driven by the verification status).
  final bool verified;
  final bool featured;
  final num ratingAverage;
  final num ratingCount;
  final num sessionsCount;

  /// Cheapest active session, minor units.
  final num? fromPriceMinor;
  final String currency;

  /// First bookable slot (UTC) from real availability minus bookings; null when none in 60 days.
  final DateTime? nextAvailableAt;
  final String timeZone;

  /// Offers at least one video call session.
  final bool videoCall;
  final String bio;
  final num yearsExperience;
  final List<DisciplineRefDto> disciplines;
  final List<CredentialOutDto> credentials;

  /// Active session types only.
  final List<SessionTypeDto> sessionTypes;
  final BookingGateDto booking;

  Map<String, Object?> toJson() => _$MentorDetailDtoToJson(this);
}
