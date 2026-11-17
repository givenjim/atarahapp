// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_account_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAccountPreferencesDto _$UpdateAccountPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => UpdateAccountPreferencesDto(
  appearance: json['appearance'] == null
      ? null
      : UpdateAccountPreferencesDtoAppearance.fromJson(
          json['appearance'] as String,
        ),
  locale: json['locale'] as String?,
  timeZone: json['timeZone'] as String?,
  marketingOptIn: json['marketingOptIn'] as bool?,
);

Map<String, dynamic> _$UpdateAccountPreferencesDtoToJson(
  UpdateAccountPreferencesDto instance,
) => <String, dynamic>{
  'appearance': instance.appearance,
  'locale': instance.locale,
  'timeZone': instance.timeZone,
  'marketingOptIn': instance.marketingOptIn,
};
