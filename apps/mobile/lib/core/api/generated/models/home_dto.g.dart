// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeDto _$HomeDtoFromJson(Map<String, dynamic> json) => HomeDto(
  firstName: json['firstName'] as String,
  completionPercent: json['completionPercent'] as num,
  unreadNotifications: json['unreadNotifications'] as num,
  recommended: (json['recommended'] as List<dynamic>)
      .map((e) => RecommendationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  creatives: (json['creatives'] as List<dynamic>)
      .map((e) => CreativeCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  unavailable: (json['unavailable'] as List<dynamic>)
      .map((e) => HomeDtoUnavailable.fromJson(e as String))
      .toList(),
  article: json['article'] == null
      ? null
      : ArticleCardDto.fromJson(json['article'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HomeDtoToJson(HomeDto instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'completionPercent': instance.completionPercent,
  'unreadNotifications': instance.unreadNotifications,
  'article': instance.article,
  'recommended': instance.recommended,
  'creatives': instance.creatives,
  'unavailable': instance.unavailable,
};
