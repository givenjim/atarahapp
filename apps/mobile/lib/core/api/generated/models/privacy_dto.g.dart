// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacyDto _$PrivacyDtoFromJson(Map<String, dynamic> json) => PrivacyDto(
  fields: (json['fields'] as List<dynamic>)
      .map((e) => PrivacyFieldDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PrivacyDtoToJson(PrivacyDto instance) =>
    <String, dynamic>{'fields': instance.fields};
