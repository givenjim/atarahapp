// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposed_session_type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposedSessionTypeDto _$ProposedSessionTypeDtoFromJson(
  Map<String, dynamic> json,
) => ProposedSessionTypeDto(
  name: json['name'] as String,
  durationMinutes: json['durationMinutes'] as num,
  priceMinor: json['priceMinor'] as num,
  sessionCount: json['sessionCount'] as num? ?? 1,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProposedSessionTypeDtoToJson(
  ProposedSessionTypeDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'priceMinor': instance.priceMinor,
  'sessionCount': instance.sessionCount,
};
