// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunities_home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunitiesHomeDto _$OpportunitiesHomeDtoFromJson(
  Map<String, dynamic> json,
) => OpportunitiesHomeDto(
  savedCount: json['savedCount'] as num,
  categories: (json['categories'] as List<dynamic>)
      .map(
        (e) => OpportunityCategoryCountDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  featured: (json['featured'] as List<dynamic>)
      .map((e) => OpportunityCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  closingSoon: (json['closingSoon'] as List<dynamic>)
      .map((e) => OpportunityCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  recent: (json['recent'] as List<dynamic>)
      .map((e) => OpportunityCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpportunitiesHomeDtoToJson(
  OpportunitiesHomeDto instance,
) => <String, dynamic>{
  'savedCount': instance.savedCount,
  'categories': instance.categories,
  'featured': instance.featured,
  'closingSoon': instance.closingSoon,
  'recent': instance.recent,
};
