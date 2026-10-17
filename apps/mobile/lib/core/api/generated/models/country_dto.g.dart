// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryDto _$CountryDtoFromJson(Map<String, dynamic> json) => CountryDto(
  id: json['id'] as String,
  isoCode: json['isoCode'] as String,
  name: json['name'] as String,
  callingCode: json['callingCode'] as String,
);

Map<String, dynamic> _$CountryDtoToJson(CountryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isoCode': instance.isoCode,
      'name': instance.name,
      'callingCode': instance.callingCode,
    };
