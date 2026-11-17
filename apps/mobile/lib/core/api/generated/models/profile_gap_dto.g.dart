// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_gap_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileGapDto _$ProfileGapDtoFromJson(Map<String, dynamic> json) =>
    ProfileGapDto(
      verdict: ProfileGapDtoVerdict.fromJson(json['verdict'] as String),
      metCount: json['metCount'] as num,
      missingCount: json['missingCount'] as num,
      unknownCount: json['unknownCount'] as num,
      blockingMissingCount: json['blockingMissingCount'] as num,
      rules: (json['rules'] as List<dynamic>)
          .map((e) => RuleResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileGapDtoToJson(ProfileGapDto instance) =>
    <String, dynamic>{
      'verdict': instance.verdict,
      'metCount': instance.metCount,
      'missingCount': instance.missingCount,
      'unknownCount': instance.unknownCount,
      'blockingMissingCount': instance.blockingMissingCount,
      'rules': instance.rules,
    };
