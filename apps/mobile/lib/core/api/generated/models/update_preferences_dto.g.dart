// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePreferencesDto _$UpdatePreferencesDtoFromJson(
  Map<String, dynamic> json,
) => UpdatePreferencesDto(
  preferences: (json['preferences'] as List<dynamic>)
      .map((e) => PreferenceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdatePreferencesDtoToJson(
  UpdatePreferencesDto instance,
) => <String, dynamic>{'preferences': instance.preferences};
