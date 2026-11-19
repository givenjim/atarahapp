// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingReviewDto _$ListingReviewDtoFromJson(Map<String, dynamic> json) =>
    ListingReviewDto(
      id: json['id'] as String,
      rating: json['rating'] as num,
      reviewerName: json['reviewerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      body: json['body'] as String?,
      reviewerAvatarUrl: json['reviewerAvatarUrl'] as String?,
    );

Map<String, dynamic> _$ListingReviewDtoToJson(ListingReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'body': instance.body,
      'reviewerName': instance.reviewerName,
      'reviewerAvatarUrl': instance.reviewerAvatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };
