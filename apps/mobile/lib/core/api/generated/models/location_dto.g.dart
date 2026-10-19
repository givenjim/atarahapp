// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => LocationDto(
  countryName: json['countryName'] as String?,
  countyName: json['countyName'] as String?,
  town: json['town'] as String?,
);

Map<String, dynamic> _$LocationDtoToJson(LocationDto instance) =>
    <String, dynamic>{
      'countryName': instance.countryName,
      'countyName': instance.countyName,
      'town': instance.town,
    };
