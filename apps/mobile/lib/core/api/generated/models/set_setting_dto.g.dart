// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_setting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetSettingDto _$SetSettingDtoFromJson(Map<String, dynamic> json) =>
    SetSettingDto(
      value: json['value'],
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SetSettingDtoToJson(SetSettingDto instance) =>
    <String, dynamic>{
      'value': instance.value,
      'description': instance.description,
    };
