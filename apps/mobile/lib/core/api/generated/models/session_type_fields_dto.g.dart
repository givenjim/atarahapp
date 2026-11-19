// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_type_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionTypeFieldsDto _$SessionTypeFieldsDtoFromJson(
  Map<String, dynamic> json,
) => SessionTypeFieldsDto(
  name: json['name'] as String,
  durationMinutes: json['durationMinutes'] as num,
  priceMinor: json['priceMinor'] as num,
  sessionCount: json['sessionCount'] as num? ?? 1,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SessionTypeFieldsDtoToJson(
  SessionTypeFieldsDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'priceMinor': instance.priceMinor,
  'sessionCount': instance.sessionCount,
};
