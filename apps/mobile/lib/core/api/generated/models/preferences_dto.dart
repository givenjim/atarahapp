// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'preference_dto.dart';

part 'preferences_dto.g.dart';

@JsonSerializable()
class PreferencesDto {
  const PreferencesDto({required this.preferences});

  factory PreferencesDto.fromJson(Map<String, Object?> json) =>
      _$PreferencesDtoFromJson(json);

  /// One entry per category. Categories never changed are on.
  final List<PreferenceDto> preferences;

  Map<String, Object?> toJson() => _$PreferencesDtoToJson(this);
}
