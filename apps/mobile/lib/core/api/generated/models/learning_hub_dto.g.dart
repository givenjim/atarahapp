// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_hub_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningHubDto _$LearningHubDtoFromJson(Map<String, dynamic> json) =>
    LearningHubDto(
      featured: (json['featured'] as List<dynamic>)
          .map((e) => LearningCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => HubCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommended: (json['recommended'] as List<dynamic>)
          .map((e) => RecommendedDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      continueLearning: json['continueLearning'] == null
          ? null
          : ContinueLearningDto.fromJson(
              json['continueLearning'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LearningHubDtoToJson(LearningHubDto instance) =>
    <String, dynamic>{
      'continueLearning': instance.continueLearning,
      'featured': instance.featured,
      'categories': instance.categories,
      'recommended': instance.recommended,
    };
