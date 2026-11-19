// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionTypeDto _$SessionTypeDtoFromJson(Map<String, dynamic> json) =>
    SessionTypeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      durationMinutes: json['durationMinutes'] as num,
      priceMinor: json['priceMinor'] as num,
      currency: json['currency'] as String,
      format: MentorSessionFormat.fromJson(json['format'] as String),
      sessionCount: json['sessionCount'] as num,
      active: json['active'] as bool,
      disabledByStaff: json['disabledByStaff'] as bool,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SessionTypeDtoToJson(SessionTypeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'priceMinor': instance.priceMinor,
      'currency': instance.currency,
      'format': instance.format,
      'sessionCount': instance.sessionCount,
      'active': instance.active,
      'disabledByStaff': instance.disabledByStaff,
    };
