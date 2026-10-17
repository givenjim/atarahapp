// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferenceDto _$PreferenceDtoFromJson(Map<String, dynamic> json) =>
    PreferenceDto(
      category: PreferenceDtoCategory.fromJson(json['category'] as String),
      pushEnabled: json['pushEnabled'] as bool,
      emailEnabled: json['emailEnabled'] as bool,
    );

Map<String, dynamic> _$PreferenceDtoToJson(PreferenceDto instance) =>
    <String, dynamic>{
      'category': instance.category,
      'pushEnabled': instance.pushEnabled,
      'emailEnabled': instance.emailEnabled,
    };
