// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_seller_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSellerDto _$AdminSellerDtoFromJson(Map<String, dynamic> json) =>
    AdminSellerDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      ratingCount: json['ratingCount'] as num,
      completedCount: json['completedCount'] as num,
      listingCount: json['listingCount'] as num,
      verified: json['verified'] as bool,
      userId: json['userId'] as String,
      email: json['email'] as String,
      status: SellerStatus.fromJson(json['status'] as String),
      verificationStatus: VerificationStatus.fromJson(
        json['verificationStatus'] as String,
      ),
      canPublishDirectly: json['canPublishDirectly'] as bool,
      termsVersion: json['termsVersion'] as String,
      termsAcceptedAt: DateTime.parse(json['termsAcceptedAt'] as String),
      liveListings: json['liveListings'] as num,
      underReviewListings: json['underReviewListings'] as num,
      openReports: json['openReports'] as num,
      handle: json['handle'] as String?,
      headline: json['headline'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      ratingAverage: json['ratingAverage'] as num?,
      suspendedReason: json['suspendedReason'] as String?,
    );

Map<String, dynamic> _$AdminSellerDtoToJson(AdminSellerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'handle': instance.handle,
      'headline': instance.headline,
      'avatarUrl': instance.avatarUrl,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'completedCount': instance.completedCount,
      'listingCount': instance.listingCount,
      'verified': instance.verified,
      'userId': instance.userId,
      'email': instance.email,
      'status': instance.status,
      'verificationStatus': instance.verificationStatus,
      'canPublishDirectly': instance.canPublishDirectly,
      'termsVersion': instance.termsVersion,
      'termsAcceptedAt': instance.termsAcceptedAt.toIso8601String(),
      'suspendedReason': instance.suspendedReason,
      'liveListings': instance.liveListings,
      'underReviewListings': instance.underReviewListings,
      'openReports': instance.openReports,
    };
