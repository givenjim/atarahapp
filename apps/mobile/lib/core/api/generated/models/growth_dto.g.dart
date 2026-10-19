// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthDto _$GrowthDtoFromJson(Map<String, dynamic> json) => GrowthDto(
  score: json['score'] as num,
  strength: GrowthDtoStrength.fromJson(json['strength'] as String),
  bars: (json['bars'] as List<dynamic>)
      .map((e) => GrowthBarDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GrowthDtoToJson(GrowthDto instance) => <String, dynamic>{
  'score': instance.score,
  'strength': instance.strength,
  'bars': instance.bars,
};
