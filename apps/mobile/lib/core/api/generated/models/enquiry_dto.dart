// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enquiry_dto_role.dart';
import 'enquiry_party_dto.dart';
import 'enquiry_status.dart';

part 'enquiry_dto.g.dart';

@JsonSerializable()
class EnquiryDto {
  const EnquiryDto({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.status,
    required this.role,
    required this.counterpart,
    required this.message,
    required this.unread,
    required this.lastMessageAt,
    required this.createdAt,
    required this.canReview,
    required this.canClose,
    required this.reviewed,
    this.listingCoverUrl,
    this.budget,
    this.preferredTiming,
    this.closedAt,
  });
  
  factory EnquiryDto.fromJson(Map<String, Object?> json) => _$EnquiryDtoFromJson(json);
  
  final String id;
  final String listingId;
  final String listingTitle;
  final String? listingCoverUrl;
  final EnquiryStatus status;

  /// Which side the viewer is.
  final EnquiryDtoRole role;

  /// The other person.
  final EnquiryPartyDto counterpart;
  final String message;

  /// Whole shillings.
  final num? budget;
  final String? preferredTiming;

  /// There is something the viewer has not read.
  final bool unread;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime? closedAt;

  /// The buyer may leave a review now.
  final bool canReview;

  /// The viewer may close it now.
  final bool canClose;

  /// A review has been left.
  final bool reviewed;

  Map<String, Object?> toJson() => _$EnquiryDtoToJson(this);
}
