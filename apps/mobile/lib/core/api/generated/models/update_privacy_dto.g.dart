// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_privacy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePrivacyDto _$UpdatePrivacyDtoFromJson(Map<String, dynamic> json) =>
    UpdatePrivacyDto(
      field: PrivacyField.fromJson(json['field'] as String),
      visibility: Visibility.fromJson(json['visibility'] as String),
    );

Map<String, dynamic> _$UpdatePrivacyDtoToJson(UpdatePrivacyDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'visibility': instance.visibility,
    };
