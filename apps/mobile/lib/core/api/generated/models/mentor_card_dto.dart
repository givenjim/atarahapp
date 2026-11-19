// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'mentor_card_dto.g.dart';

@JsonSerializable()
class MentorCardDto {
  const MentorCardDto({
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
    this.handle,
    this.avatarUrl,
    this.fromPriceMinor,
    this.nextAvailableAt,
  });
  
  factory MentorCardDto.fromJson(Map<String, Object?> json) => _$MentorCardDtoFromJson(json);
  
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

  Map<String, Object?> toJson() => _$MentorCardDtoToJson(this);
}
