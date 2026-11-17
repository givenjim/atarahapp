// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedDto _$RecommendedDtoFromJson(Map<String, dynamic> json) =>
    RecommendedDto(
      content: LearningCardDto.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RecommendedDtoToJson(RecommendedDto instance) =>
    <String, dynamic>{'content': instance.content, 'reason': instance.reason};
