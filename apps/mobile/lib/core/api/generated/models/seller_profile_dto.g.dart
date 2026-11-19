// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerProfileDto _$SellerProfileDtoFromJson(Map<String, dynamic> json) =>
    SellerProfileDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      ratingCount: json['ratingCount'] as num,
      completedCount: json['completedCount'] as num,
      listingCount: json['listingCount'] as num,
      verified: json['verified'] as bool,
      userId: json['userId'] as String,
      trustLines: (json['trustLines'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberSince: DateTime.parse(json['memberSince'] as String),
      listings: (json['listings'] as List<dynamic>)
          .map((e) => ListingCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasProfile: json['hasProfile'] as bool,
      handle: json['handle'] as String?,
      headline: json['headline'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      ratingAverage: json['ratingAverage'] as num?,
      medianReplyMinutes: json['medianReplyMinutes'] as num?,
      replyLabel: json['replyLabel'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$SellerProfileDtoToJson(SellerProfileDto instance) =>
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
      'medianReplyMinutes': instance.medianReplyMinutes,
      'replyLabel': instance.replyLabel,
      'trustLines': instance.trustLines,
      'bio': instance.bio,
      'location': instance.location,
      'memberSince': instance.memberSince.toIso8601String(),
      'listings': instance.listings,
      'hasProfile': instance.hasProfile,
    };
