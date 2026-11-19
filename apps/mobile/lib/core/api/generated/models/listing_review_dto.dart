// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'listing_review_dto.g.dart';

@JsonSerializable()
class ListingReviewDto {
  const ListingReviewDto({
    required this.id,
    required this.rating,
    required this.reviewerName,
    required this.createdAt,
    this.body,
    this.reviewerAvatarUrl,
  });
  
  factory ListingReviewDto.fromJson(Map<String, Object?> json) => _$ListingReviewDtoFromJson(json);
  
  final String id;
  final num rating;
  final String? body;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$ListingReviewDtoToJson(this);
}
