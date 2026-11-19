// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'review_visibility.dart';

part 'admin_review_dto.g.dart';

@JsonSerializable()
class AdminReviewDto {
  const AdminReviewDto({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.reviewerName,
    required this.rating,
    required this.status,
    required this.createdAt,
    this.body,
    this.hiddenReason,
  });
  
  factory AdminReviewDto.fromJson(Map<String, Object?> json) => _$AdminReviewDtoFromJson(json);
  
  final String id;
  final String listingId;
  final String listingTitle;
  final String reviewerName;
  final num rating;
  final String? body;
  final ReviewVisibility status;
  final String? hiddenReason;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminReviewDtoToJson(this);
}
