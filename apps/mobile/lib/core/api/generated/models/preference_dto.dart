// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'preference_dto_category.dart';

part 'preference_dto.g.dart';

@JsonSerializable()
class PreferenceDto {
  const PreferenceDto({
    required this.category,
    required this.pushEnabled,
    required this.emailEnabled,
  });

  factory PreferenceDto.fromJson(Map<String, Object?> json) =>
      _$PreferenceDtoFromJson(json);

  final PreferenceDtoCategory category;
  final bool pushEnabled;
  final bool emailEnabled;

  Map<String, Object?> toJson() => _$PreferenceDtoToJson(this);
}
