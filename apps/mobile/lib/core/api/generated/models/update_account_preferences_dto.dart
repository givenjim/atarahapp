// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_account_preferences_dto_appearance.dart';

part 'update_account_preferences_dto.g.dart';

@JsonSerializable()
class UpdateAccountPreferencesDto {
  const UpdateAccountPreferencesDto({
    this.appearance,
    this.locale,
    this.timeZone,
    this.marketingOptIn,
  });

  factory UpdateAccountPreferencesDto.fromJson(Map<String, Object?> json) =>
      _$UpdateAccountPreferencesDtoFromJson(json);

  final UpdateAccountPreferencesDtoAppearance? appearance;

  /// BCP 47 language tag, e.g. en or sw.
  final String? locale;

  /// IANA time zone.
  final String? timeZone;
  final bool? marketingOptIn;

  Map<String, Object?> toJson() => _$UpdateAccountPreferencesDtoToJson(this);
}
