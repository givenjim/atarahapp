// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPreferencesDto _$AccountPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => AccountPreferencesDto(
  appearance: AccountPreferencesDtoAppearance.fromJson(
    json['appearance'] as String,
  ),
  locale: json['locale'] as String,
  timeZone: json['timeZone'] as String,
  marketingOptIn: json['marketingOptIn'] as bool,
);

Map<String, dynamic> _$AccountPreferencesDtoToJson(
  AccountPreferencesDto instance,
) => <String, dynamic>{
  'appearance': instance.appearance,
  'locale': instance.locale,
  'timeZone': instance.timeZone,
  'marketingOptIn': instance.marketingOptIn,
};
