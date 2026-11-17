// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_field_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacyFieldDto _$PrivacyFieldDtoFromJson(Map<String, dynamic> json) =>
    PrivacyFieldDto(
      field: PrivacyField.fromJson(json['field'] as String),
      label: json['label'] as String,
      visibility: Visibility.fromJson(json['visibility'] as String),
      defaultVisibility: Visibility.fromJson(
        json['defaultVisibility'] as String,
      ),
    );

Map<String, dynamic> _$PrivacyFieldDtoToJson(PrivacyFieldDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'label': instance.label,
      'visibility': instance.visibility,
      'defaultVisibility': instance.defaultVisibility,
    };
