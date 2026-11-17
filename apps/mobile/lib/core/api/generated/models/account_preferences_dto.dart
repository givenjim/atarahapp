// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_preferences_dto_appearance.dart';

part 'account_preferences_dto.g.dart';

@JsonSerializable()
class AccountPreferencesDto {
  const AccountPreferencesDto({
    required this.appearance,
    required this.locale,
    required this.timeZone,
    required this.marketingOptIn,
  });

  factory AccountPreferencesDto.fromJson(Map<String, Object?> json) =>
      _$AccountPreferencesDtoFromJson(json);

  final AccountPreferencesDtoAppearance appearance;
  final String locale;
  final String timeZone;
  final bool marketingOptIn;

  Map<String, Object?> toJson() => _$AccountPreferencesDtoToJson(this);
}
