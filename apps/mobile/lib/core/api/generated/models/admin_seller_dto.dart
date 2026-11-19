// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'seller_status.dart';
import 'verification_status.dart';

part 'admin_seller_dto.g.dart';

@JsonSerializable()
class AdminSellerDto {
  const AdminSellerDto({
    required this.id,
    required this.displayName,
    required this.ratingCount,
    required this.completedCount,
    required this.listingCount,
    required this.verified,
    required this.userId,
    required this.email,
    required this.status,
    required this.verificationStatus,
    required this.canPublishDirectly,
    required this.termsVersion,
    required this.termsAcceptedAt,
    required this.liveListings,
    required this.underReviewListings,
    required this.openReports,
    this.handle,
    this.headline,
    this.avatarUrl,
    this.ratingAverage,
    this.suspendedReason,
  });
  
  factory AdminSellerDto.fromJson(Map<String, Object?> json) => _$AdminSellerDtoFromJson(json);
  
  /// The seller profile id.
  final String id;
  final String displayName;
  final String? handle;
  final String? headline;
  final String? avatarUrl;
  final num? ratingAverage;
  final num ratingCount;
  final num completedCount;

  /// Published listings.
  final num listingCount;

  /// True only when the seller is verified by Atarah (written by P2-M6).
  final bool verified;
  final String userId;
  final String email;
  final SellerStatus status;
  final VerificationStatus verificationStatus;
  final bool canPublishDirectly;
  final String termsVersion;
  final DateTime termsAcceptedAt;
  final String? suspendedReason;
  final num liveListings;
  final num underReviewListings;
  final num openReports;

  Map<String, Object?> toJson() => _$AdminSellerDtoToJson(this);
}
