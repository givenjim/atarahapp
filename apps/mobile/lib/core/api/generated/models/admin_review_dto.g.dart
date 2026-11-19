// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminReviewDto _$AdminReviewDtoFromJson(Map<String, dynamic> json) =>
    AdminReviewDto(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      listingTitle: json['listingTitle'] as String,
      reviewerName: json['reviewerName'] as String,
      rating: json['rating'] as num,
      status: ReviewVisibility.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      body: json['body'] as String?,
      hiddenReason: json['hiddenReason'] as String?,
    );

Map<String, dynamic> _$AdminReviewDtoToJson(AdminReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
      'reviewerName': instance.reviewerName,
      'rating': instance.rating,
      'body': instance.body,
      'status': instance.status,
      'hiddenReason': instance.hiddenReason,
      'createdAt': instance.createdAt.toIso8601String(),
    };
