// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeConfigDto _$HomeConfigDtoFromJson(Map<String, dynamic> json) =>
    HomeConfigDto(
      featuredArticleId: json['featuredArticleId'] as String?,
      featuredArticleTitle: json['featuredArticleTitle'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$HomeConfigDtoToJson(HomeConfigDto instance) =>
    <String, dynamic>{
      'featuredArticleId': instance.featuredArticleId,
      'featuredArticleTitle': instance.featuredArticleTitle,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
