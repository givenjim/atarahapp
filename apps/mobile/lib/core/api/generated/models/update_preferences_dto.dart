// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'preference_dto.dart';

part 'update_preferences_dto.g.dart';

@JsonSerializable()
class UpdatePreferencesDto {
  const UpdatePreferencesDto({required this.preferences});

  factory UpdatePreferencesDto.fromJson(Map<String, Object?> json) =>
      _$UpdatePreferencesDtoFromJson(json);

  final List<PreferenceDto> preferences;

  Map<String, Object?> toJson() => _$UpdatePreferencesDtoToJson(this);
}
